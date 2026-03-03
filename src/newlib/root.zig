pub const libc = @import("libc.zig");
pub const abort = libc.abort;

pub const module_name = "newlib";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"newlib"};
pub const embedded_files = .{};
