const EmbeddedFile = @import("../../idf/cmake/component.zig").EmbeddedFile;

pub const module_name = "esp_wifi";
pub const idf_requires = &.{ "esp_wifi", "esp_event", "esp_netif", "nvs_flash" };
pub const embedded_files: []const EmbeddedFile = &.{
    .{ .path = "c_helper.c", .content = @embedFile("c_helper.c") },
    .{ .path = "c_helper.h", .content = @embedFile("c_helper.h") },
};

pub const sdkconfig = @import("sdkconfig.zig");
