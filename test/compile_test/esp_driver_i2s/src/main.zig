const esp = @import("esp");
const esp_driver_i2s = esp.component.esp_driver_i2s;
comptime {
    _ = esp_driver_i2s.Role;
    _ = esp_driver_i2s.BitsPerSample;
    _ = esp_driver_i2s.SlotMode;
    _ = esp_driver_i2s.ChannelMode;
    _ = esp_driver_i2s.RxConfig;
    _ = esp_driver_i2s.TxConfig;
    _ = esp_driver_i2s.DuplexConfig;
    _ = esp_driver_i2s.I2sRx;
    _ = esp_driver_i2s.I2sTx;
    _ = esp_driver_i2s.I2sDuplex;
    _ = esp_driver_i2s.Error;
}
export fn zig_esp_main() callconv(.c) void {}
