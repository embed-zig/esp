const esp_adc = @import("esp_adc");
comptime {
    _ = esp_adc.Oneshot;
}
export fn zig_esp_main() callconv(.c) void {}
