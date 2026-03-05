pub const heap = @import("heap.zig");
pub const freeHeapSize = heap.freeHeapSize;
pub const minimumFreeHeapSize = heap.minimumFreeHeapSize;
pub const freeInternalHeapSize = heap.freeInternalHeapSize;
pub const capsGetFreeSize = heap.capsGetFreeSize;
pub const capsGetTotalSize = heap.capsGetTotalSize;
pub const capsGetMinimumFreeSize = heap.capsGetMinimumFreeSize;
pub const capsMalloc = heap.capsMalloc;
pub const capsFree = heap.capsFree;

pub const caps = @import("caps.zig");
pub const Caps = caps.Caps;

pub const alloc = @import("allocator.zig");
pub const HeapCapsAllocator = alloc.HeapCapsAllocator;
pub const heapCapsAllocator = alloc.heapCapsAllocator;
pub const psram = alloc.psram;
pub const iram = alloc.iram;
pub const dram = alloc.dram;
pub const default = alloc.default;

pub const module_name = "heap";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"heap"};
pub const embedded_files = .{
    .{
        .path = @as([]const u8, "c_helper.c"),
        .content = @embedFile("c_helper.c"),
    },
};
