pub const led_strip = @import("led_strip.zig");
pub const LedStrip = led_strip.LedStrip;
pub const StripConfig = led_strip.StripConfig;
pub const RmtConfig = led_strip.RmtConfig;
pub const SpiConfig = led_strip.SpiConfig;
pub const LedModel = led_strip.LedModel;
pub const ColorComponentFormat = led_strip.ColorComponentFormat;
pub const Error = led_strip.Error;
pub const check = led_strip.check;

pub const module_name = "led_strip";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{ "espressif__led_strip", "esp_driver_rmt", "esp_driver_spi" };
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
    .{ .path = @as([]const u8, "c_helper.h"), .content = @embedFile("c_helper.h") },
};

pub const idf_external_components = [_]struct { name: []const u8, version: []const u8 }{
    .{ .name = "espressif/led_strip", .version = "^3.0.0" },
};
