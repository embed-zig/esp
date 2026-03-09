const esp = @import("esp");
const esp_cpu = esp.component.esp_cpu;

comptime {
    _ = esp_cpu.getCoreCount;
}

export fn zig_esp_main() callconv(.c) void {}
