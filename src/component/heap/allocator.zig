const std = @import("std");
const Caps = @import("caps.zig").Caps;
const Alignment = std.mem.Alignment;

extern fn espz_heap_caps_malloc(size: usize, caps: u32) ?[*]u8;
extern fn espz_heap_caps_realloc(ptr: ?*anyopaque, size: usize, caps: u32) ?[*]u8;
extern fn espz_heap_caps_free(ptr: ?*anyopaque) void;

extern fn espz_heap_malloc(size: usize) ?[*]u8;
extern fn espz_heap_realloc(ptr: ?*anyopaque, size: usize) ?[*]u8;
extern fn espz_heap_free(ptr: ?*anyopaque) void;

/// A `std.mem.Allocator` backed by ESP-IDF `heap_caps_*` functions.
///
/// Parameterised by capability flags so callers can create allocators
/// targeting different memory regions (DMA, PSRAM, internal, etc.).
///
/// Usage (runtime only — caps are resolved via extern calls):
/// ```
/// const heap = @import("heap");
/// var state = heap.alloc.heapCapsAllocator(heap.Caps.dma());
/// const alloc = state.allocator();
/// const buf = try alloc.alloc(u8, 1024);
/// defer alloc.free(buf);
/// ```
pub const HeapCapsAllocator = struct {
    caps_fn: *const fn () u32,
    caps_cache: u32 = 0,
    inited: bool = false,

    pub fn init(caps_fn: *const fn () u32) HeapCapsAllocator {
        return .{ .caps_fn = caps_fn };
    }

    fn getCaps(self: *HeapCapsAllocator) u32 {
        if (!self.inited) {
            self.caps_cache = self.caps_fn();
            self.inited = true;
        }
        return self.caps_cache;
    }

    pub fn allocator(self: *HeapCapsAllocator) std.mem.Allocator {
        return .{
            .ptr = @ptrCast(self),
            .vtable = &vtable,
        };
    }

    const vtable: std.mem.Allocator.VTable = .{
        .alloc = vtAlloc,
        .resize = vtResize,
        .remap = vtRemap,
        .free = vtFree,
    };

    fn vtAlloc(ctx: *anyopaque, len: usize, ptr_align: Alignment, _: usize) ?[*]u8 {
        const self: *HeapCapsAllocator = @ptrCast(@alignCast(ctx));
        const alignment = ptr_align.toByteUnits();
        const caps = self.getCaps();

        if (alignment <= @sizeOf(usize)) {
            return espz_heap_caps_malloc(len, caps);
        }

        const padded = len + alignment - 1;
        const raw = espz_heap_caps_malloc(padded + @sizeOf(usize), caps) orelse return null;
        const raw_addr = @intFromPtr(raw);
        const aligned_addr = (raw_addr + @sizeOf(usize) + alignment - 1) & ~(alignment - 1);
        const header: *[*]u8 = @ptrFromInt(aligned_addr - @sizeOf(usize));
        header.* = raw;
        return @ptrFromInt(aligned_addr);
    }

    /// In-place resize. Only shrinking is safe because `heap_caps_realloc`
    /// may relocate the block when growing, which would invalidate the
    /// original pointer the caller still holds. Shrinking never relocates
    /// in ESP-IDF's multi-heap implementation, so we allow it.
    /// High-alignment allocations use a padding+header scheme that
    /// `heap_caps_realloc` is unaware of, so we refuse those entirely.
    fn vtResize(ctx: *anyopaque, buf: []u8, ptr_align: Alignment, new_len: usize, _: usize) bool {
        if (new_len > buf.len) return false;

        const alignment = ptr_align.toByteUnits();
        if (alignment > @sizeOf(usize)) return false;

        const self: *HeapCapsAllocator = @ptrCast(@alignCast(ctx));
        const caps = self.getCaps();
        const result = espz_heap_caps_realloc(@ptrCast(buf.ptr), new_len, caps) orelse return false;
        // Shrink must not relocate; if it did something is very wrong.
        return result == buf.ptr;
    }

    /// Resize with possible relocation, backed by `heap_caps_realloc`.
    /// Returns the (possibly moved) pointer on success, or `null` if the
    /// operation cannot be performed — in which case the caller falls back
    /// to alloc + copy + free.
    /// High-alignment allocations store a hidden header before the user
    /// pointer; `heap_caps_realloc` would corrupt that layout, so we
    /// return `null` and let the caller handle it.
    fn vtRemap(ctx: *anyopaque, buf: []u8, ptr_align: Alignment, new_len: usize, _: usize) ?[*]u8 {
        const alignment = ptr_align.toByteUnits();
        if (alignment > @sizeOf(usize)) return null;

        const self: *HeapCapsAllocator = @ptrCast(@alignCast(ctx));
        const caps = self.getCaps();
        return espz_heap_caps_realloc(@ptrCast(buf.ptr), new_len, caps);
    }

    fn vtFree(_: *anyopaque, buf: []u8, ptr_align: Alignment, _: usize) void {
        const alignment = ptr_align.toByteUnits();

        if (alignment <= @sizeOf(usize)) {
            espz_heap_caps_free(@ptrCast(buf.ptr));
            return;
        }

        const header: *[*]u8 = @ptrFromInt(@intFromPtr(buf.ptr) - @sizeOf(usize));
        espz_heap_caps_free(@ptrCast(header.*));
    }
};

fn psramCaps() u32 {
    return Caps.defaultPsram().raw;
}

fn iramCaps() u32 {
    return Caps.iram_8bit().raw;
}

fn dramCaps() u32 {
    return Caps.defaultInternal().raw;
}

var psram_state: HeapCapsAllocator = HeapCapsAllocator.init(&psramCaps);
var iram_state: HeapCapsAllocator = HeapCapsAllocator.init(&iramCaps);
var dram_state: HeapCapsAllocator = HeapCapsAllocator.init(&dramCaps);

/// `std.mem.Allocator` backed by byte-addressable PSRAM (`spiram | 8bit`).
pub const psram: std.mem.Allocator = psram_state.allocator();

/// `std.mem.Allocator` backed by byte-addressable IRAM (`iram_8bit`).
pub const iram: std.mem.Allocator = iram_state.allocator();

/// `std.mem.Allocator` backed by byte-addressable internal DRAM (`internal | 8bit`).
pub const dram: std.mem.Allocator = dram_state.allocator();

/// A `std.mem.Allocator` backed by the standard C `malloc`/`realloc`/`free`.
///
/// The actual memory region depends on ESP-IDF sdkconfig:
/// - Default: allocates from internal DRAM.
/// - With `CONFIG_SPIRAM_USE_MALLOC` enabled: `malloc` automatically falls
///   back to PSRAM when internal memory is insufficient.
///
/// This is the simplest allocator — use it when you don't need explicit
/// control over which memory region is used.
const DefaultAllocator = struct {
    const vtable: std.mem.Allocator.VTable = .{
        .alloc = vtAlloc,
        .resize = vtResize,
        .remap = vtRemap,
        .free = vtFree,
    };

    fn vtAlloc(_: *anyopaque, len: usize, ptr_align: Alignment, _: usize) ?[*]u8 {
        const alignment = ptr_align.toByteUnits();

        if (alignment <= @sizeOf(usize)) {
            return espz_heap_malloc(len);
        }

        const padded = len + alignment - 1;
        const raw = espz_heap_malloc(padded + @sizeOf(usize)) orelse return null;
        const raw_addr = @intFromPtr(raw);
        const aligned_addr = (raw_addr + @sizeOf(usize) + alignment - 1) & ~(alignment - 1);
        const header: *[*]u8 = @ptrFromInt(aligned_addr - @sizeOf(usize));
        header.* = raw;
        return @ptrFromInt(aligned_addr);
    }

    fn vtResize(_: *anyopaque, buf: []u8, ptr_align: Alignment, new_len: usize, _: usize) bool {
        if (new_len > buf.len) return false;

        const alignment = ptr_align.toByteUnits();
        if (alignment > @sizeOf(usize)) return false;

        const result = espz_heap_realloc(@ptrCast(buf.ptr), new_len) orelse return false;
        return result == buf.ptr;
    }

    fn vtRemap(_: *anyopaque, buf: []u8, ptr_align: Alignment, new_len: usize, _: usize) ?[*]u8 {
        const alignment = ptr_align.toByteUnits();
        if (alignment > @sizeOf(usize)) return null;

        return espz_heap_realloc(@ptrCast(buf.ptr), new_len);
    }

    fn vtFree(_: *anyopaque, buf: []u8, ptr_align: Alignment, _: usize) void {
        const alignment = ptr_align.toByteUnits();

        if (alignment <= @sizeOf(usize)) {
            espz_heap_free(@ptrCast(buf.ptr));
            return;
        }

        const header: *[*]u8 = @ptrFromInt(@intFromPtr(buf.ptr) - @sizeOf(usize));
        espz_heap_free(@ptrCast(header.*));
    }
};

/// `std.mem.Allocator` backed by standard `malloc`/`realloc`/`free`.
///
/// Memory region is controlled by ESP-IDF sdkconfig:
/// - Default: internal DRAM only.
/// - `CONFIG_SPIRAM_USE_MALLOC`: auto-fallback to PSRAM when DRAM is full.
pub const default: std.mem.Allocator = .{
    .ptr = undefined,
    .vtable = &DefaultAllocator.vtable,
};

/// Create a `HeapCapsAllocator` for custom capability flags.
///
/// The returned struct owns the state; keep it alive for the allocator's
/// lifetime. Call `.allocator()` to obtain the `std.mem.Allocator` interface.
pub fn heapCapsAllocator(caps_fn: *const fn () u32) HeapCapsAllocator {
    return HeapCapsAllocator.init(caps_fn);
}
