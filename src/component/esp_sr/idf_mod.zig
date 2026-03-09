const EmbeddedFile = @import("../../idf/cmake/component.zig").EmbeddedFile;

pub const module_name = "esp_sr";
pub const idf_requires = &.{ "espressif__esp-sr", "partition_table" };
pub const embedded_files: []const EmbeddedFile = &.{
    .{ .path = "c_helper.c", .content = @embedFile("c_helper.c") },
};
const ExternalComponent = @import("../../idf/cmake/component.zig").ExternalComponent;
pub const idf_external_components: []const ExternalComponent = &.{
    .{ .name = "espressif/esp-sr", .version = "2.3.1" },
};

pub const sdkconfig = @import("sdkconfig.zig");
