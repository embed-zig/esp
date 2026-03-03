pub const backlight = @import("backlight.zig");
pub const backlightInit = backlight.backlightInit;
pub const setDutyPercent = backlight.setDutyPercent;

pub const module_name = "esp_driver_ledc";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"esp_driver_ledc"};
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
};
