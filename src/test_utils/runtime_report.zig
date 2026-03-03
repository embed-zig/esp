const std = @import("std");
const log = @import("../esp_system/log.zig");

pub const MemoryUsage = struct {
    used: u32,
    free: u32,
    total: u32,
};

pub const RuntimeSnapshot = struct {
    stable_runtime_seconds: u32,
    iram: MemoryUsage,
    psram: MemoryUsage,
};

pub fn logStartup(message: []const u8) void {
    log.info(message);
}

pub fn formatStableLine(seconds: u32, buffer: []u8) ![]const u8 {
    return std.fmt.bufPrint(buffer, "stable_runtime_seconds={d}", .{seconds});
}

pub fn formatUsageLine(comptime label: []const u8, usage: MemoryUsage, buffer: []u8) ![]const u8 {
    return std.fmt.bufPrint(
        buffer,
        "{s}_usage_bytes used={d} free={d} total={d}",
        .{ label, usage.used, usage.free, usage.total },
    );
}

test "formatStableLine generates expected payload" {
    var buf: [64]u8 = undefined;
    const line = try formatStableLine(28, &buf);
    try std.testing.expectEqualStrings("stable_runtime_seconds=28", line);
}

test "formatUsageLine generates expected payload" {
    var buf: [96]u8 = undefined;
    const line = try formatUsageLine(
        "iram",
        .{
            .used = 17244,
            .free = 390340,
            .total = 407584,
        },
        &buf,
    );
    try std.testing.expectEqualStrings(
        "iram_usage_bytes used=17244 free=390340 total=407584",
        line,
    );
}
