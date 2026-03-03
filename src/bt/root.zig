pub const vhci = @import("vhci.zig");
pub const VHci = vhci.VHci;

pub const controller = @import("controller.zig");

pub const module_name = "bt";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"bt"};
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
    .{ .path = @as([]const u8, "c_helper.h"), .content = @embedFile("c_helper.h") },
};
