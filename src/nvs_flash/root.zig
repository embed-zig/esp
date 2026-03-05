pub const nvs = @import("nvs.zig");
pub const init = nvs.init;
pub const deinit = nvs.deinit;
pub const erase = nvs.erase;
pub const Namespace = nvs.Namespace;

pub const module_name = "nvs_flash";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"nvs_flash"};
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
};
