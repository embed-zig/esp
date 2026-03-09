const esp = @import("esp");
const esp_random = esp.component.esp_random;

comptime {
    _ = esp_random.fill;
}

export fn zig_esp_main() callconv(.c) void {}
