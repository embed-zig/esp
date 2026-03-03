pub const wifi = @import("wifi.zig");
pub const WiFi = wifi.WiFi;

pub const module_name = "esp_wifi";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{ "esp_wifi", "esp_event", "esp_netif", "nvs_flash" };
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
    .{ .path = @as([]const u8, "c_helper.h"), .content = @embedFile("c_helper.h") },
};
