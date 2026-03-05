const esp_random = @import("esp_random");

comptime {
    _ = esp_random.fill;
}

export fn zig_esp_main() callconv(.c) void {}
