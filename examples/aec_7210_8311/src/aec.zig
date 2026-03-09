const std = @import("std");

const SAMPLE_RATE: u32 = 16_000;

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
