//! app_metadata module: sdkconfig bindings + OTA operations.

pub const config = @import("config.zig");
pub const ota = @import("ota.zig");

pub const module_name = "app_metadata";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{ "app_update", "esp_partition" };
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
};
