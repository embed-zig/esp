const esp_lcd = @import("esp_lcd");

comptime {
    _ = esp_lcd.Panel;
    _ = esp_lcd.Error;
    _ = esp_lcd.check;
    _ = esp_lcd.spi.Bus;
    _ = esp_lcd.spi.PanelIo;
    _ = esp_lcd.driver.st7789;
    _ = esp_lcd.driver.ili9341;
}

export fn zig_esp_main() callconv(.c) void {}
