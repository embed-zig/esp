const std = @import("std");
const esp = @import("esp");
const esp_component = esp.component;
const rom = esp_component.esp_rom;
const freertos = esp_component.freertos;
const heap = esp_component.heap;
const esp_sr = esp_component.esp_sr;

const brd = @import("board.zig");
const Board = brd.Board;
const AudioDriver = brd.AudioDriver;

const printf = rom.esp_rom_printf;

const SAMPLE_RATE: u32 = 16_000;
const AEC_FRAME_LEN: u32 = 256;
const NS_FRAME_LEN: u32 = 160;

const CAPTURE_FRAMES: u32 = 200;
const CAPTURE_SAMPLES: u32 = CAPTURE_FRAMES * AEC_FRAME_LEN;

const MUSIC_DURATION_SEC: u32 = 5;
const MUSIC_TOTAL_SAMPLES: u32 = SAMPLE_RATE * MUSIC_DURATION_SEC;

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

fn computeRms(data: []const i16) u32 {
    if (data.len == 0) return 0;
    var sum: u64 = 0;
    for (data) |s| {
        const v: i64 = @intCast(s);
        sum += @intCast(v * v);
    }
    const mean = sum / @as(u64, @intCast(data.len));
    return @intCast(std.math.sqrt(mean));
}

fn playBuf(audio: *AudioDriver, buf: []const i16, len: u32) void {
    var pos: u32 = 0;
    while (pos < len) {
        const rem = len - pos;
        const chunk = if (rem > AEC_FRAME_LEN) AEC_FRAME_LEN else rem;
        _ = audio.writeSpk(buf[pos .. pos + chunk]) catch break;
        _ = audio.readFrame() catch {};
        pos += chunk;
    }
}

const Note = struct { freq: u16, dur_ms: u16 };

const melody_notes = [_]Note{
    .{ .freq = 262, .dur_ms = 300 }, .{ .freq = 262, .dur_ms = 300 },
    .{ .freq = 392, .dur_ms = 300 }, .{ .freq = 392, .dur_ms = 300 },
    .{ .freq = 440, .dur_ms = 300 }, .{ .freq = 440, .dur_ms = 300 },
    .{ .freq = 392, .dur_ms = 600 }, .{ .freq = 349, .dur_ms = 300 },
    .{ .freq = 349, .dur_ms = 300 }, .{ .freq = 330, .dur_ms = 300 },
    .{ .freq = 330, .dur_ms = 300 }, .{ .freq = 294, .dur_ms = 300 },
    .{ .freq = 294, .dur_ms = 300 }, .{ .freq = 262, .dur_ms = 600 },
};

fn generateMelody(buf: []i16) void {
    var pos: u32 = 0;
    const total: u32 = @intCast(buf.len);
    const fade_samples: u32 = SAMPLE_RATE / 20;

    for (melody_notes) |note| {
        const note_samples: u32 = @as(u32, note.dur_ms) * SAMPLE_RATE / 1000;

        for (0..note_samples) |i| {
            if (pos >= total) return;
            const phase: f32 = @as(f32, @floatFromInt(i)) * @as(f32, @floatFromInt(note.freq)) / @as(f32, @floatFromInt(SAMPLE_RATE));
            var sample: f32 = @sin(phase * 2.0 * std.math.pi);

            if (i < fade_samples) {
                sample *= @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(fade_samples));
            } else if (i > note_samples - fade_samples) {
                sample *= @as(f32, @floatFromInt(note_samples - i)) / @as(f32, @floatFromInt(fade_samples));
            }

            buf[pos] = @intFromFloat(sample * 8000.0);
            pos += 1;
        }
    }

    while (pos < total) : (pos += 1) {
        buf[pos] = 0;
    }
}

fn flushAudio(audio: *AudioDriver) void {
    var silence: [AEC_FRAME_LEN]i16 = @splat(0);
    for (0..10) |_| {
        _ = audio.writeSpk(&silence) catch break;
    }
}

fn playBeeps(audio: *AudioDriver) void {
    const beep_freq: u32 = 1000;
    const beep_ms: u32 = 100;
    const gap_ms: u32 = 100;
    const beep_samples = SAMPLE_RATE * beep_ms / 1000;
    const gap_samples = SAMPLE_RATE * gap_ms / 1000;

    var tone: [AEC_FRAME_LEN]i16 = undefined;
    var silence: [AEC_FRAME_LEN]i16 = @splat(0);

    for (0..2) |beep_idx| {
        var sent: u32 = 0;
        while (sent < beep_samples) {
            const remain = beep_samples - sent;
            const n = if (remain > AEC_FRAME_LEN) AEC_FRAME_LEN else remain;
            for (0..n) |i| {
                const t = sent + @as(u32, @intCast(i));
                const phase: f32 = @as(f32, @floatFromInt(t)) * @as(f32, @floatFromInt(beep_freq)) / @as(f32, @floatFromInt(SAMPLE_RATE));
                tone[i] = @intFromFloat(@sin(phase * 2.0 * std.math.pi) * 6000.0);
            }
            _ = audio.writeSpk(tone[0..n]) catch break;
            _ = audio.readFrame() catch {};
            sent += @intCast(n);
        }

        if (beep_idx == 0) {
            var gap_sent: u32 = 0;
            while (gap_sent < gap_samples) {
                const remain = gap_samples - gap_sent;
                const n = if (remain > AEC_FRAME_LEN) AEC_FRAME_LEN else remain;
                _ = audio.writeSpk(silence[0..n]) catch break;
                _ = audio.readFrame() catch {};
                gap_sent += @intCast(n);
            }
        }
    }
}

export fn zig_esp_main() callconv(.c) void {
    _ = printf("\n========================================\n");
    _ = printf("  AEC+NS+AGC Test (hal audio_system)\n");
    _ = printf("========================================\n\n");

    _ = printf("heap: total=%u internal=%u\n", heap.freeHeapSize(), heap.freeInternalHeapSize());

    // ── [1] Board init ──
    _ = printf("[1] Board init...\n");
    const board = Board.init(heap.alloc.psram) orelse {
        _ = printf("FATAL: board init failed\n");
        return;
    };
    const audio = board.audio;
    audio.start() catch {
        _ = printf("FATAL: audio start failed\n");
        return;
    };
    _ = printf("heap after board: total=%u internal=%u\n", heap.freeHeapSize(), heap.freeInternalHeapSize());

    // ── [2] Audio pipeline init: AEC -> NS -> AGC ──
    _ = printf("\n[2] Creating audio pipeline...\n");

    const aec_inst = esp_sr.Aec.init(.{
        .sample_rate = SAMPLE_RATE,
        .filter_length = 4,
        .channel_num = 1,
        .mode = .voip_high_perf,
    }) catch {
        _ = printf("FATAL: AEC create failed\n");
        return;
    };
    const aec_chunk = aec_inst.getChunksize() catch 256;
    _ = printf("  AEC OK (chunk=%d)\n", aec_chunk);

    const ns_inst = esp_sr.Ns.init(.{
        .frame_length = .ms10,
        .mode = .medium,
        .sample_rate = SAMPLE_RATE,
    }) catch {
        _ = printf("FATAL: NS create failed\n");
        return;
    };
    _ = printf("  NS  OK (10ms, medium)\n");

    const agc_inst = esp_sr.Agc.init(.{
        .mode = .mode_2,
        .sample_rate = SAMPLE_RATE,
        .gain_db = 15,
        .limiter_enable = true,
        .target_level_dbfs = -3,
    }) catch {
        _ = printf("FATAL: AGC create failed\n");
        return;
    };
    _ = printf("  AGC OK (gain=15dB, target=-3dBFS)\n");
    _ = printf("  heap after pipeline: total=%u internal=%u\n", heap.freeHeapSize(), heap.freeInternalHeapSize());

    // ── [3] Allocate buffers in PSRAM ──
    _ = printf("\n[3] Allocating buffers in PSRAM...\n");
    const psram = heap.alloc.psram;

    const mic1_buf = psram.alloc(i16, CAPTURE_SAMPLES) catch {
        _ = printf("FATAL: alloc mic1\n");
        return;
    };
    const ref_buf = psram.alloc(i16, CAPTURE_SAMPLES) catch {
        _ = printf("FATAL: alloc ref\n");
        return;
    };
    const aec_out_buf = psram.alloc(i16, CAPTURE_SAMPLES) catch {
        _ = printf("FATAL: alloc aec_out\n");
        return;
    };
    const clean_buf = psram.alloc(i16, CAPTURE_SAMPLES) catch {
        _ = printf("FATAL: alloc clean\n");
        return;
    };
    const music = psram.alloc(i16, MUSIC_TOTAL_SAMPLES) catch {
        _ = printf("FATAL: alloc music\n");
        return;
    };

    const aec_chunk_sz: u32 = @intCast(aec_chunk);
    _ = printf("heap after alloc: total=%u internal=%u\n", heap.freeHeapSize(), heap.freeInternalHeapSize());

    // ── [4] Generate melody ──
    _ = printf("\n[4] Generating melody (%u samples, %u sec)...\n", MUSIC_TOTAL_SAMPLES, MUSIC_DURATION_SEC);
    generateMelody(music);

    // ── [5] Capture while playing ──
    _ = printf("\n[5] Playing melody + capturing mic/ref (%u frames)...\n", CAPTURE_FRAMES);
    Board.paEnable(true);

    var play_pos: u32 = 0;
    var cap_pos: u32 = 0;
    var frames: u32 = 0;

    while (cap_pos + AEC_FRAME_LEN <= CAPTURE_SAMPLES and play_pos < MUSIC_TOTAL_SAMPLES) {
        const remaining = MUSIC_TOTAL_SAMPLES - play_pos;
        const chunk = if (remaining > AEC_FRAME_LEN) AEC_FRAME_LEN else remaining;

        _ = audio.writeSpk(music[play_pos .. play_pos + chunk]) catch break;

        const frame = audio.readFrame() catch continue;

        if (frames == 10) {
            _ = printf("  [diag] mic views: ");
            for (0..4) |vi| {
                if (frame.mic[vi].len > 0) {
                    _ = printf("v%u(len=%u,rms=%u) ", @as(u32, @intCast(vi)), @as(u32, @intCast(frame.mic[vi].len)), computeRms(frame.mic[vi]));
                } else {
                    _ = printf("v%u(empty) ", @as(u32, @intCast(vi)));
                }
            }
            _ = printf("\n");
            _ = printf("  [diag] ref rms=%u\n", computeRms(frame.ref));
            _ = printf("  [diag] raw TDM ch rms: ");
            for (0..4) |ch| {
                const buf = audio.mic_buffers[ch][0..audio.frame_samples];
                _ = printf("ch%u=%u ", @as(u32, @intCast(ch)), computeRms(buf));
            }
            _ = printf("\n");
        }

        const mic_data = frame.mic[0];
        const ref_data = frame.ref;
        const store = @min(mic_data.len, CAPTURE_SAMPLES - cap_pos);

        @memcpy(mic1_buf[cap_pos .. cap_pos + store], mic_data[0..store]);
        @memcpy(ref_buf[cap_pos .. cap_pos + store], ref_data[0..store]);

        play_pos += chunk;
        cap_pos += @intCast(store);
        frames += 1;

        if (frames % 50 == 0) {
            _ = printf("  frame %u, cap %u/%u\n", frames, cap_pos, CAPTURE_SAMPLES);
        }
    }

    flushAudio(audio);
    Board.paEnable(false);
    _ = printf("  captured %u samples in %u frames\n", cap_pos, frames);

    const rms_start = cap_pos / 4;
    const rms_end = cap_pos * 3 / 4;
    const rms_mic = computeRms(mic1_buf[rms_start..rms_end]);
    const rms_ref = computeRms(ref_buf[rms_start..rms_end]);
    _ = printf("  MIC1 RMS: %u  REF RMS: %u\n", rms_mic, rms_ref);

    // ── [6] AEC ──
    _ = printf("\n[6] AEC processing...\n");
    {
        var pos: u32 = 0;
        while (pos + aec_chunk_sz <= cap_pos) {
            aec_inst.process(
                mic1_buf[pos .. pos + aec_chunk_sz],
                ref_buf[pos .. pos + aec_chunk_sz],
                aec_out_buf[pos .. pos + aec_chunk_sz],
            ) catch break;
            pos += aec_chunk_sz;
        }
        const rms_aec = computeRms(aec_out_buf[rms_start..rms_end]);
        _ = printf("  AEC  RMS: %u (mic1 was %u)\n", rms_aec, rms_mic);
    }

    // ── [7] NS on AEC output ──
    _ = printf("\n[7] NS processing...\n");
    {
        var ns_tmp: [NS_FRAME_LEN]i16 = undefined;
        var pos: u32 = 0;
        while (pos + NS_FRAME_LEN <= cap_pos) {
            ns_inst.process(
                aec_out_buf[pos .. pos + NS_FRAME_LEN],
                &ns_tmp,
            ) catch break;
            @memcpy(clean_buf[pos .. pos + NS_FRAME_LEN], &ns_tmp);
            pos += NS_FRAME_LEN;
        }
        if (pos < cap_pos) {
            @memcpy(clean_buf[pos..cap_pos], aec_out_buf[pos..cap_pos]);
        }
        const rms_ns = computeRms(clean_buf[rms_start..rms_end]);
        _ = printf("  NS   RMS: %u\n", rms_ns);
    }

    // ── [8] AGC on NS output (in-place on clean_buf) ──
    _ = printf("\n[8] AGC processing...\n");
    {
        var agc_tmp: [NS_FRAME_LEN]i16 = undefined;
        var pos: u32 = 0;
        while (pos + NS_FRAME_LEN <= cap_pos) {
            agc_inst.process(
                clean_buf[pos .. pos + NS_FRAME_LEN],
                &agc_tmp,
                NS_FRAME_LEN,
            ) catch break;
            @memcpy(clean_buf[pos .. pos + NS_FRAME_LEN], &agc_tmp);
            pos += NS_FRAME_LEN;
        }
        const rms_agc = computeRms(clean_buf[rms_start..rms_end]);
        _ = printf("  AGC  RMS: %u\n", rms_agc);
    }

    // ── Playback: MIC1 -> beep -> AEC -> beep -> AEC+NS+AGC ──

    // [9] Play MIC1 (raw)
    _ = printf("\n[9] Playing MIC1 (raw, RMS=%u)...\n", rms_mic);
    Board.paEnable(true);
    playBuf(audio, mic1_buf, cap_pos);
    flushAudio(audio);
    Board.paEnable(false);

    freertos.delay(300);
    Board.paEnable(true);
    playBeeps(audio);
    flushAudio(audio);
    Board.paEnable(false);
    freertos.delay(300);

    // [10] Play AEC output
    _ = printf("\n[10] Playing AEC output (RMS=%u)...\n", computeRms(aec_out_buf[rms_start..rms_end]));
    Board.paEnable(true);
    playBuf(audio, aec_out_buf, cap_pos);
    flushAudio(audio);
    Board.paEnable(false);

    freertos.delay(300);
    Board.paEnable(true);
    playBeeps(audio);
    flushAudio(audio);
    Board.paEnable(false);
    freertos.delay(300);

    // [11] Play AEC+NS+AGC output
    _ = printf("\n[11] Playing AEC+NS+AGC output (RMS=%u)...\n", computeRms(clean_buf[rms_start..rms_end]));
    Board.paEnable(true);
    playBuf(audio, clean_buf, cap_pos);
    flushAudio(audio);
    Board.paEnable(false);

    // ── Summary ──
    _ = printf("\n========================================\n");
    _ = printf("  Summary\n");
    _ = printf("========================================\n");
    _ = printf("  MIC1 RMS: %u  REF RMS: %u\n", rms_mic, rms_ref);
    _ = printf("  AEC  RMS: %u\n", computeRms(aec_out_buf[rms_start..rms_end]));
    _ = printf("  NS   RMS: %u\n", computeRms(clean_buf[rms_start..rms_end]));
    _ = printf("  Captured: %u samples\n", cap_pos);
    _ = printf("  heap final: total=%u internal=%u\n", heap.freeHeapSize(), heap.freeInternalHeapSize());
    _ = printf("========================================\n");

    aec_inst.deinit();
    ns_inst.deinit();
    agc_inst.deinit();

    while (true) {
        freertos.delay(10000);
    }
}
