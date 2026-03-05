const esp_driver_gpio = @import("esp_driver_gpio");
comptime {
    _ = esp_driver_gpio.setDirection;
    _ = esp_driver_gpio.setLevel;
    _ = esp_driver_gpio.getLevel;
    _ = esp_driver_gpio.GpioMode;
    _ = esp_driver_gpio.GpioPull;
    _ = esp_driver_gpio.Error;
}
export fn zig_esp_main() callconv(.c) void {}
