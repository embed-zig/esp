const std = @import("std");
const i2s = @import("esp").component.esp_driver_i2s;

const SAMPLE_RATE: u32 = 16_000;
const AEC_FRAME_LEN: u32 = 512;

/// Convert mono i16 samples to 32-bit stereo I2S TX format.
/// Each i16 sample is left-shifted 16 bits into the high half of an i32,
/// then duplicated to both L and R channels.
pub fn mono16ToStereo32(src: []const i16, dst: []u8) usize {
    const out: []i32 = @alignCast(std.mem.bytesAsSlice(i32, dst));
    for (0..src.len) |idx| {
        const s: i32 = @as(i32, src[idx]) << 16;
        out[idx * 2 + 0] = s;
        out[idx * 2 + 1] = s;
    }
    return src.len * 2 * @sizeOf(i32);
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

pub fn generateMelody(buf: []i16) void {
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

pub fn flushI2sDma(duplex: i2s.I2sDuplex, write_buf: []u8) void {
    var silence: [AEC_FRAME_LEN]i16 = @splat(0);
    for (0..10) |_| {
        const write_len = mono16ToStereo32(&silence, write_buf);
        _ = duplex.write(write_buf[0..write_len], 1000) catch break;
    }
}

/// Play two short beeps (1kHz, 100ms each, 100ms gap) as an audible separator.
pub fn playBeeps(duplex: i2s.I2sDuplex, write_buf: []u8, read_buf: []u8) void {
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
            const write_len = mono16ToStereo32(tone[0..n], write_buf);
            _ = duplex.write(write_buf[0..write_len], 1000) catch break;
            _ = duplex.read(read_buf, 1000) catch {};
            sent += @intCast(n);
        }

        if (beep_idx == 0) {
            var gap_sent: u32 = 0;
            while (gap_sent < gap_samples) {
                const remain = gap_samples - gap_sent;
                const n = if (remain > AEC_FRAME_LEN) AEC_FRAME_LEN else remain;
                const write_len = mono16ToStereo32(silence[0..n], write_buf);
                _ = duplex.write(write_buf[0..write_len], 1000) catch break;
                _ = duplex.read(read_buf, 1000) catch {};
                gap_sent += @intCast(n);
            }
        }
    }
}
