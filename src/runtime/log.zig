const std = @import("std");
const esp_rom = @import("../component/esp_rom/rom.zig");

pub const Log = struct {
    pub fn debug(_: Log, msg: []const u8) void {
        printTagged("[debug]", msg);
    }

    pub fn info(_: Log, msg: []const u8) void {
        printTagged("[info]", msg);
    }

    pub fn warn(_: Log, msg: []const u8) void {
        printTagged("[warn]", msg);
    }

    pub fn err(_: Log, msg: []const u8) void {
        printTagged("[error]", msg);
    }
};

fn printTagged(comptime tag: [*:0]const u8, msg: []const u8) void {
    var buf: [256]u8 = undefined;
    const copy_len = @min(msg.len, buf.len - 1);
    @memcpy(buf[0..copy_len], msg[0..copy_len]);
    buf[copy_len] = 0;
    esp_rom.printf("%s %s\n", .{ tag, @as([*:0]const u8, @ptrCast(&buf)) });
}
