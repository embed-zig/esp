const esp = @import("esp");
const esp_timer = esp.component.esp_timer;

comptime {
    _ = esp_timer.getTimeUs;
    _ = esp_timer.getTimeMs;
}

export fn zig_esp_main() callconv(.c) void {}
