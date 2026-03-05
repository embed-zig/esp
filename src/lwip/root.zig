//! lwip module: sdkconfig bindings + BSD socket API.

pub const config = @import("config.zig");
pub const socket = @import("socket.zig");

pub const module_name = "lwip";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"lwip"};
pub const embedded_files = .{
    .{
        .path = @as([]const u8, "c_helper.c"),
        .content = @embedFile("c_helper.c"),
    },
};
