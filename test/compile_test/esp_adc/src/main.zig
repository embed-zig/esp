const esp = @import("esp");
const esp_adc = esp.component.esp_adc;
comptime {
    _ = esp_adc.Oneshot;
}
export fn zig_esp_main() callconv(.c) void {}
