const EmbeddedFile = @import("../../idf/cmake/component.zig").EmbeddedFile;

pub const module_name = "led_strip";
pub const idf_requires = &.{ "espressif__led_strip", "esp_driver_rmt", "esp_driver_spi" };
pub const embedded_files: []const EmbeddedFile = &.{
    .{ .path = "c_helper.c", .content = @embedFile("c_helper.c") },
    .{ .path = "c_helper.h", .content = @embedFile("c_helper.h") },
};
const ExternalComponent = @import("../../idf/cmake/component.zig").ExternalComponent;
pub const idf_external_components: []const ExternalComponent = &.{
    .{ .name = "espressif/led_strip", .version = "^3.0.0" },
};

pub const sdkconfig = @import("sdkconfig.zig");
