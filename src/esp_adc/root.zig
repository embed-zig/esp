pub const oneshot = @import("oneshot.zig");
pub const Oneshot = oneshot.Oneshot;

pub const module_name = "esp_adc";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"esp_adc"};
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
};
