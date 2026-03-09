const EmbeddedFile = @import("../../idf/cmake/component.zig").EmbeddedFile;

pub const module_name = "bt";
pub const idf_requires = &.{"bt"};
pub const embedded_files: []const EmbeddedFile = &.{
    .{ .path = "c_helper.c", .content = @embedFile("c_helper.c") },
    .{ .path = "c_helper.h", .content = @embedFile("c_helper.h") },
};
pub const sdkconfig_guard = "CONFIG_BT_ENABLED";

pub const sdkconfig = @import("sdkconfig.zig");
