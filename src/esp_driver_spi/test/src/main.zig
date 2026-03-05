const esp_driver_spi = @import("esp_driver_spi");
comptime {
    _ = esp_driver_spi.SpiMaster;
    _ = esp_driver_spi.Config;
    _ = esp_driver_spi.Error;
}
export fn zig_esp_main() callconv(.c) void {}
