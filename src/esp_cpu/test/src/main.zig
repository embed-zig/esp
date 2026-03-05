const esp_cpu = @import("esp_cpu");

comptime {
    _ = esp_cpu.getCoreCount;
}

export fn zig_esp_main() callconv(.c) void {}
