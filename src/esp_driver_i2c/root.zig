pub const master = @import("master.zig");
pub const I2cMaster = master.I2cMaster;
pub const Config = master.Config;
pub const Error = master.Error;

pub const module_name = "esp_driver_i2c";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{ "driver", "esp_driver_i2c" };
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
};
