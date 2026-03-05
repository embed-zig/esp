//! esp_netif module: sdkconfig bindings + network interface runtime API.

pub const config = @import("config.zig");
pub const netif = @import("netif.zig");

pub const module_name = "esp_netif";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{ "esp_netif", "esp_event" };
pub const embedded_files = .{
    .{
        .path = @as([]const u8, "c_helper.c"),
        .content = @embedFile("c_helper.c"),
    },
};
