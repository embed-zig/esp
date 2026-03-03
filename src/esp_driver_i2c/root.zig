pub const master = @import("master.zig");
pub const masterInit = master.masterInit;
pub const masterWrite = master.masterWrite;
pub const masterWriteRead = master.masterWriteRead;

pub const module_name = "esp_driver_i2c";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{ "driver", "esp_driver_i2c" };
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
};
