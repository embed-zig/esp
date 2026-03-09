const EmbeddedFile = @import("../../idf/cmake/component.zig").EmbeddedFile;

pub const module_name = "esp_lcd";
pub const idf_requires = &.{ "esp_lcd", "esp_driver_spi", "driver" };
pub const embedded_files: []const EmbeddedFile = &.{
    .{ .path = "c_helper.c", .content = @embedFile("c_helper.c") },
    .{ .path = "c_helper.h", .content = @embedFile("c_helper.h") },
};

pub const sdkconfig = @import("sdkconfig.zig");
