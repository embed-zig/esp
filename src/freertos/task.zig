const std = @import("std");

extern fn vTaskDelay(ticks: u32) void;

pub const TickType = u32;

/// Delay the calling task for the given number of ticks.
pub fn delay(ticks: u32) void {
    vTaskDelay(ticks);
}

pub fn msToTicks(milliseconds: u32, tick_rate_hz: u32) TickType {
    if (tick_rate_hz == 0) return 0;

    const numerator: u64 = @as(u64, milliseconds) * @as(u64, tick_rate_hz);
    return @intCast(numerator / 1000);
}

test "msToTicks converts milliseconds with floor semantics" {
    try std.testing.expectEqual(@as(TickType, 10), msToTicks(100, 100));
    try std.testing.expectEqual(@as(TickType, 0), msToTicks(1, 100));
    try std.testing.expectEqual(@as(TickType, 0), msToTicks(100, 0));
}
