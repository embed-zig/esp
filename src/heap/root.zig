pub const heap = @import("heap.zig");
pub const freeHeapSize = heap.freeHeapSize;
pub const minimumFreeHeapSize = heap.minimumFreeHeapSize;
pub const freeInternalHeapSize = heap.freeInternalHeapSize;

pub const module_name = "heap";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"heap"};
pub const embedded_files = .{};
