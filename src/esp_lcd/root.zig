pub const panel = @import("panel.zig");
pub const spi = @import("spi.zig");
pub const driver = @import("driver.zig");

pub const Panel = panel.Panel;
pub const Error = panel.Error;
pub const check = panel.check;

pub const module_name = "esp_lcd";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{ "esp_lcd", "esp_driver_spi", "driver" };
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
    .{ .path = @as([]const u8, "c_helper.h"), .content = @embedFile("c_helper.h") },
};
