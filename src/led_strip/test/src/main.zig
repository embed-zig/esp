const led_strip = @import("led_strip");
comptime {
    _ = led_strip.LedStrip;
    _ = led_strip.StripConfig;
    _ = led_strip.RmtConfig;
    _ = led_strip.SpiConfig;
    _ = led_strip.LedModel;
    _ = led_strip.ColorComponentFormat;
    _ = led_strip.Error;
    _ = led_strip.check;
}
export fn zig_esp_main() callconv(.c) void {}
