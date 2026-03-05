const esp_driver_i2c = @import("esp_driver_i2c");

comptime {
    _ = esp_driver_i2c.I2cMaster;
    _ = esp_driver_i2c.Config;
    _ = esp_driver_i2c.Error;
}

export fn zig_esp_main() callconv(.c) void {}
