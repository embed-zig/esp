const std = @import("std");
const esp = @import("esp");
const esp_component = esp.component;
const rom = esp_component.esp_rom;

const printf = rom.esp_rom_printf;

pub const SAMPLE_RATE: u32 = 16_000;
pub const AUDIO_DURATION_S: u32 = 3;
pub const TOTAL_SAMPLES: u32 = SAMPLE_RATE * AUDIO_DURATION_S;

const far_end_embed = @embedFile("far_end.raw");
const near_end_embed = @embedFile("near_end.raw");

pub const far_end_pcm: []const i16 = bytesToI16(far_end_embed);
pub const near_end_pcm: []const i16 = bytesToI16(near_end_embed);

fn bytesToI16(bytes: []const u8) []const i16 {
    return @alignCast(std.mem.bytesAsSlice(i16, bytes));
}

/// Copy embedded audio data into a mutable PSRAM buffer.
pub fn loadAudio(label: [*:0]const u8, buf: []i16, embedded: []const i16) void {
    const n = @min(buf.len, embedded.len);
    @memcpy(buf[0..n], embedded[0..n]);
    if (n < buf.len) @memset(std.mem.sliceAsBytes(buf[n..]), 0);
    _ = printf("  '%s': loaded %u samples from embedded data (@embedFile)\n", label, @as(u32, @intCast(n)));
}

pub fn computeRms(data: []const i16) u32 {
    if (data.len == 0) return 0;
    var sum: u64 = 0;
    for (data) |s| {
        const v: i64 = @intCast(s);
        sum += @intCast(v * v);
    }
    const mean = sum / @as(u64, @intCast(data.len));
    return @intCast(std.math.sqrt(mean));
}

pub fn computePeakAbs(data: []const i16) u16 {
    var peak: u16 = 0;
    for (data) |s| {
        const abs: u16 = if (s < 0) @intCast(-@as(i32, s)) else @intCast(s);
        if (abs > peak) peak = abs;
    }
    return peak;
}
