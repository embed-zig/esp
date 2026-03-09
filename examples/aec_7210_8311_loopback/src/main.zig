const std = @import("std");
const esp = @import("esp");
const esp_component = esp.component;
const rom = esp_component.esp_rom;
const freertos = esp_component.freertos;
const heap = esp_component.heap;
const esp_sr = esp_component.esp_sr;

const aec_util = @import("aec.zig");
const brd = @import("board.zig");
const Board = brd.Board;

const printf = rom.esp_rom_printf;

const SAMPLE_RATE: u32 = 16_000;

// voip_high_perf chunk = 256 samples
const AEC_FRAME_LEN: u32 = 256;
const I2S_FRAME_BYTES: u32 = AEC_FRAME_LEN * 2 * @sizeOf(i32);

var i2s_read_buf: [I2S_FRAME_BYTES]u8 align(4) = undefined;
var i2s_write_buf: [I2S_FRAME_BYTES]u8 align(4) = undefined;

extern fn abort() noreturn;

pub const std_options: std.Options = .{
    .logFn = struct {
        fn log(
            comptime _: std.log.Level,
            comptime _: @TypeOf(.enum_literal),
            comptime _: []const u8,
            _: anytype,
        ) void {}
    }.log,
};

pub fn panic(msg: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    _ = printf("\n*** ZIG PANIC ***\n");
    for (msg) |ch| {
        _ = printf("%c", @as(i32, ch));
    }
    _ = printf("\n*****************\n");
    abort();
}

fn decodeRx(raw: []const u8, mic1: []i16, mic2: []i16, ref: []i16) usize {
    const samples: []const i32 = @alignCast(std.mem.bytesAsSlice(i32, raw));
    const frame_count = samples.len / 2;
    for (0..frame_count) |idx| {
        const l: i32 = samples[idx * 2 + 0];
        const r: i32 = samples[idx * 2 + 1];
        mic1[idx] = @truncate(l >> 16);
        ref[idx] = @truncate(l & 0xFFFF);
        mic2[idx] = @truncate(r >> 16);
    }
    return frame_count;
}

export fn zig_esp_main() callconv(.c) void {
    _ = printf("\n========================================\n");
    _ = printf("  AEC Real-time Loopback\n");
    _ = printf("========================================\n\n");

    _ = printf("heap: total=%u internal=%u\n", heap.freeHeapSize(), heap.freeInternalHeapSize());

    // ── Board init ──
    _ = printf("[1] Board init...\n");
    const board = Board.init() orelse {
        _ = printf("FATAL: board init failed\n");
        return;
    };
    const duplex = board.duplex orelse {
        _ = printf("FATAL: no I2S duplex\n");
        return;
    };

    // ── AEC init ──
    _ = printf("[2] Creating AEC...\n");
    const aec_inst = esp_sr.Aec.init(.{
        .sample_rate = SAMPLE_RATE,
        .filter_length = 4,
        .channel_num = 1,
        .mode = .voip_high_perf,
    }) catch {
        _ = printf("FATAL: AEC create failed\n");
        return;
    };
    const aec_chunk: u32 = @intCast(aec_inst.getChunksize() catch 256);
    _ = printf("  AEC OK (chunk=%u, mode=voip_high_perf)\n", aec_chunk);
    _ = printf("  heap: total=%u internal=%u\n", heap.freeHeapSize(), heap.freeInternalHeapSize());

    // ── Real-time loopback ──
    _ = printf("\n[3] Starting real-time loopback (speak into mic)...\n");
    _ = printf("    MIC1 -> AEC(mic1, ref) -> Speaker\n\n");

    Board.paEnable(true);

    var mic1_frame: [AEC_FRAME_LEN]i16 = undefined;
    var mic2_frame: [AEC_FRAME_LEN]i16 = undefined;
    var ref_frame: [AEC_FRAME_LEN]i16 = undefined;
    var aec_out: [AEC_FRAME_LEN]i16 = undefined;

    // Send a few silent frames to prime the I2S DMA pipeline
    {
        var silence: [AEC_FRAME_LEN]i16 = @splat(0);
        for (0..4) |_| {
            const wlen = aec_util.mono16ToStereo32(&silence, &i2s_write_buf);
            _ = duplex.write(i2s_write_buf[0..wlen], 1000) catch {};
        }
    }

    var loop_count: u32 = 0;
    while (true) {
        // Read mic + ref from ES7210 (32-bit stereo TDM packed)
        const bytes_read = duplex.read(&i2s_read_buf, 1000) catch continue;
        if (bytes_read < I2S_FRAME_BYTES) continue;

        const n = decodeRx(i2s_read_buf[0..bytes_read], &mic1_frame, &mic2_frame, &ref_frame);
        if (n == 0) continue;

        const frame_len: u32 = @intCast(n);

        // AEC: process in aec_chunk-sized blocks
        var pos: u32 = 0;
        while (pos + aec_chunk <= frame_len) {
            aec_inst.process(
                mic1_frame[pos .. pos + aec_chunk],
                ref_frame[pos .. pos + aec_chunk],
                aec_out[pos .. pos + aec_chunk],
            ) catch break;
            pos += aec_chunk;
        }
        // Pass through any remaining samples that don't fill a full AEC chunk
        while (pos < frame_len) : (pos += 1) {
            aec_out[pos] = mic1_frame[pos];
        }

        // Write AEC output to speaker via ES8311
        const wlen = aec_util.mono16ToStereo32(aec_out[0..frame_len], &i2s_write_buf);
        _ = duplex.write(i2s_write_buf[0..wlen], 1000) catch {};

        loop_count += 1;
        if (loop_count % 500 == 0) {
            _ = printf("  [loopback] %u frames processed\n", loop_count);
        }
    }
}
