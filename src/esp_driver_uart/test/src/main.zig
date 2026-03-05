const esp_driver_uart = @import("esp_driver_uart");

comptime {
    _ = esp_driver_uart.Config;
    _ = esp_driver_uart.init;
    _ = esp_driver_uart.deinit;
    _ = esp_driver_uart.read;
    _ = esp_driver_uart.write;
    _ = esp_driver_uart.bufferedLen;
}

export fn zig_esp_main() callconv(.c) void {}
