pub const config = @import("config.zig");

pub const timer = @import("timer.zig");
pub const getTimeUs = timer.getTimeUs;
pub const getTimeMs = timer.getTimeMs;

pub const module_name = "esp_timer";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"esp_timer"};
pub const embedded_files = .{
    .{
        .path = @as([]const u8, "c_helper.c"),
        .content = @embedFile("c_helper.c"),
    },
};
