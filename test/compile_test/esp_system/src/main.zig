const esp = @import("esp");
const esp_system = esp.component.esp_system;

comptime {
    _ = esp_system.log;
}

export fn zig_esp_main() callconv(.c) void {}
