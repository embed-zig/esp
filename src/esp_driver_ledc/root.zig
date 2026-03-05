pub const config = @import("config.zig");
pub const ledc = @import("ledc.zig");

pub const Ledc = ledc.Ledc;
pub const Config = ledc.Config;
pub const TimerConfig = ledc.TimerConfig;
pub const ChannelConfig = ledc.ChannelConfig;
pub const Error = ledc.Error;

pub const module_name = "esp_driver_ledc";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"esp_driver_ledc"};
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
};
