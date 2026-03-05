pub const config = @import("config.zig");
pub const master = @import("master.zig");
pub const SpiMaster = master.SpiMaster;
pub const Config = master.Config;
pub const Error = master.Error;

pub const module_name = "esp_driver_spi";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{ "driver", "esp_driver_spi" };
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
};
