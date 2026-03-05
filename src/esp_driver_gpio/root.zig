pub const config = @import("config.zig");

pub const gpio = @import("gpio.zig");
pub const setDirection = gpio.setDirection;
pub const setLevel = gpio.setLevel;
pub const getLevel = gpio.getLevel;
pub const setPullMode = gpio.setPullMode;
pub const resetPin = gpio.resetPin;
pub const GpioMode = gpio.GpioMode;
pub const GpioPull = gpio.GpioPull;
pub const Error = gpio.Error;

pub const module_name = "esp_driver_gpio";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"esp_driver_gpio"};
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
};
