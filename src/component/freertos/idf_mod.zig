const EmbeddedFile = @import("../../idf/cmake/component.zig").EmbeddedFile;

pub const module_name = "freertos";
pub const idf_requires = &.{ "freertos", "heap" };
pub const embedded_files: []const EmbeddedFile = &.{
    .{ .path = "task_helper.c", .content = @embedFile("task_helper.c") },
    .{ .path = "queue_helper.c", .content = @embedFile("queue_helper.c") },
    .{ .path = "sync_helper.c", .content = @embedFile("sync_helper.c") },
    .{ .path = "adf_freertos_patch_compat.c", .content = @embedFile("adf_freertos_patch_compat.c") },
};

pub const sdkconfig = @import("sdkconfig.zig");
