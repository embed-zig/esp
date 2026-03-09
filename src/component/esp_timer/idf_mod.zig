const EmbeddedFile = @import("../../idf/cmake/component.zig").EmbeddedFile;

pub const module_name = "esp_timer";
pub const idf_requires = &.{"esp_timer"};
pub const embedded_files: []const EmbeddedFile = &.{
    .{ .path = "c_helper.c", .content = @embedFile("c_helper.c") },
};

pub const sdkconfig = @import("sdkconfig.zig");
