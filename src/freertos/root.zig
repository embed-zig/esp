pub const task = @import("task.zig");
pub const delay = task.delay;
pub const msToTicks = task.msToTicks;
pub const TickType = task.TickType;

pub const module_name = "freertos";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"freertos"};
pub const embedded_files = .{};
