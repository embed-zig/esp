const esp = @import("esp");
const esp_driver_ledc = esp.component.esp_driver_ledc;
comptime {
    _ = esp_driver_ledc.Ledc;
    _ = esp_driver_ledc.Config;
    _ = esp_driver_ledc.TimerConfig;
    _ = esp_driver_ledc.ChannelConfig;
    _ = esp_driver_ledc.Error;
}
export fn zig_esp_main() callconv(.c) void {}
