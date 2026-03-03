const std = @import("std");

pub fn formatStartLine(buffer: []u8) ![]const u8 {
    return std.fmt.bufPrint(buffer, "wifi_scan_start", .{});
}

pub fn formatResultLine(ap_count: u16, shown_count: u16, buffer: []u8) ![]const u8 {
    return std.fmt.bufPrint(
        buffer,
        "wifi_scan_result total={d} shown={d}",
        .{ ap_count, shown_count },
    );
}

test "formatStartLine prints fixed payload" {
    var buf: [64]u8 = undefined;
    const line = try formatStartLine(&buf);
    try std.testing.expectEqualStrings("wifi_scan_start", line);
}

test "formatResultLine prints count payload" {
    var buf: [96]u8 = undefined;
    const line = try formatResultLine(23, 10, &buf);
    try std.testing.expectEqualStrings("wifi_scan_result total=23 shown=10", line);
}
