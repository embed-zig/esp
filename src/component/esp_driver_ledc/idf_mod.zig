const EmbeddedFile = @import("../../idf/cmake/component.zig").EmbeddedFile;

pub const module_name = "esp_driver_ledc";
pub const idf_requires = &.{"esp_driver_ledc"};
pub const embedded_files: []const EmbeddedFile = &.{
    .{ .path = "c_helper.c", .content = @embedFile("c_helper.c") },
};

pub const sdkconfig = @import("sdkconfig.zig");
