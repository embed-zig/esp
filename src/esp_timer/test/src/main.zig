const esp_timer = @import("esp_timer");

comptime {
    _ = esp_timer.getTimeUs;
    _ = esp_timer.getTimeMs;
}

export fn zig_esp_main() callconv(.c) void {}
