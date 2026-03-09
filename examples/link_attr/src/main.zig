const std = @import("std");
const esp = @import("esp");
const esp_component = esp.component;
const rom = esp_component.esp_rom;
const freertos = esp_component.freertos;
const heap = esp_component.heap;

const printf = rom.esp_rom_printf;

extern fn abort() noreturn;

pub const std_options: std.Options = .{
    .logFn = struct {
        fn log(
            comptime _: std.log.Level,
            comptime _: @TypeOf(.enum_literal),
            comptime _: []const u8,
            _: anytype,
        ) void {}
    }.log,
};

pub fn panic(msg: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    _ = printf("\n*** ZIG PANIC ***\n");
    for (msg) |ch| {
        _ = printf("%c", @as(i32, ch));
    }
    _ = printf("\n*****************\n");
    abort();
}

// ============================================================================
// 1. linksection — place code/data in specific memory regions
// ============================================================================

// --- .iram1: Internal RAM (fast, survives flash cache miss, required for ISRs) ---

/// Function placed in IRAM. Equivalent to C: void IRAM_ATTR my_func(void)
/// Use for: interrupt handlers, code that runs while flash is being written.
export fn iram_fast_function() linksection(".iram1") callconv(.c) void {
    iram_counter +%= 1;
}

/// Mutable counter in DRAM, accessed from IRAM functions.
/// Note: mutable data should NOT go in .iram1 on ESP32 — IRAM is instruction
/// memory. Use .dram0.data for mutable data accessed from ISRs.
export var iram_counter: u32 linksection(".dram0.data") = 0;

// --- .dram0.data: Internal DRAM (initialized data) ---

/// Equivalent to C: DRAM_ATTR uint32_t my_var = 42;
/// Normally const data goes to flash (.rodata). This forces it into DRAM.
/// Use for: data accessed from ISRs, or when flash cache may be off.
export var dram_lookup: [4]u32 linksection(".dram0.data") = .{ 0xDEAD, 0xBEEF, 0xCAFE, 0xF00D };

// --- .rodata: Flash read-only data (default for const, shown explicitly) ---

/// Explicit .rodata placement. Normally you don't need this — any `const` is
/// already in .rodata. Shown here for completeness.
export const rodata_magic: u32 linksection(".rodata") = 0x5A5A5A5A;

// --- .noinit: RAM that is NOT zeroed/initialized on boot ---

/// Survives soft reset (esp_restart). Useful for crash counters, flags.
/// Equivalent to C: __NOINIT_ATTR uint32_t boot_count;
export var noinit_boot_count: u32 linksection(".noinit") = undefined;

// --- @embedFile: embed binary data into .rodata (flash) ---

/// The file content becomes a compile-time constant in .rodata.
/// Accessed via XIP (execute-in-place) — no RAM copy, pointer reads flash directly.
const embedded_data = @embedFile("demo_blob.bin");

// ============================================================================
// 2. align — control memory alignment
// ============================================================================

/// 32-byte aligned buffer. Useful for DMA transfers which often require
/// alignment to cache line boundaries.
/// Equivalent to C: uint8_t buf[256] __attribute__((aligned(32)));
var dma_buffer: [256]u8 align(32) = undefined;

/// 4KB aligned — e.g. for page-aligned memory-mapped regions.
var page_buffer: [4096]u8 align(4096) = undefined;

/// Alignment on struct fields.
const AlignedFields = struct {
    normal: u8,
    cache_aligned: u32 align(32),
    dma_ptr: [*]u8 align(16),
};

// ============================================================================
// 3. packed — no padding between fields, exact memory layout
// ============================================================================

/// Packed struct: fields are laid out contiguously with no padding.
/// Total size = 1 + 2 + 1 + 4 = 8 bytes (not 12 as a normal struct might be).
/// Use for: parsing binary protocols, hardware register maps, file formats.
const PacketHeader = packed struct {
    magic: u8,
    length: u16,
    flags: u8,
    sequence: u32,
};

/// Packed enum with explicit backing integer type.
const RegBits = packed struct {
    enable: bool,
    mode: u3,
    _reserved: u4 = 0,
};

// ============================================================================
// 4. export — make symbol visible to linker (equivalent to __attribute__((used)))
// ============================================================================

/// Without `export`, the linker might strip this if nothing in Zig references it.
/// With `export`, it's guaranteed to be in the final binary and callable from C.
export fn zig_exported_callback() callconv(.c) void {
    _ = printf("called from C or linker script\n");
}

// ============================================================================
// 5. noinline — prevent inlining (equivalent to __attribute__((noinline)))
// ============================================================================

/// Useful for profiling, stack traces, or ensuring a function has its own frame.
fn noinline_helper(x: u32) callconv(.c) u32 {
    @setRuntimeSafety(false);
    return x *% 31 +% 7;
}

// ============================================================================
// 6. Combining attributes
// ============================================================================

/// IRAM function + noinline: guaranteed own stack frame in internal RAM.
/// Typical for GPIO/timer ISR handlers on ESP32.
export fn iram_isr_handler() linksection(".iram1") callconv(.c) void {
    iram_counter +%= 1;
}

/// DRAM data + alignment: DMA descriptor that must be in internal RAM and aligned.
export var dma_descriptor: [32]u8 align(16) linksection(".dram0.data") = std.mem.zeroes([32]u8);

// ============================================================================
// Entry point — demonstrate and verify all the above at runtime
// ============================================================================

export fn zig_esp_main() callconv(.c) void {
    _ = printf("\n\n========================================\n");
    _ = printf("  Zig Link Attributes Demo (ESP32-S3)\n");
    _ = printf("========================================\n\n");

    // --- linksection ---
    _ = printf("[linksection]\n");

    _ = printf("  iram_fast_function @ %p (expect 0x4037xxxx IRAM range)\n", @as(*const anyopaque, @ptrCast(&iram_fast_function)));
    iram_fast_function();
    _ = printf("  iram_counter       @ %p = %u\n", @as(*const anyopaque, @ptrCast(&iram_counter)), iram_counter);

    _ = printf("  dram_lookup        @ %p = [0x%X, 0x%X, 0x%X, 0x%X]\n", @as(*const anyopaque, @ptrCast(&dram_lookup)), dram_lookup[0], dram_lookup[1], dram_lookup[2], dram_lookup[3]);

    _ = printf("  rodata_magic       @ %p = 0x%X (expect flash 0x3Cxxxxxx)\n", @as(*const anyopaque, @ptrCast(&rodata_magic)), rodata_magic);

    noinit_boot_count +%= 1;
    _ = printf("  noinit_boot_count  @ %p = %u (increments across soft resets)\n", @as(*const anyopaque, @ptrCast(&noinit_boot_count)), noinit_boot_count);

    _ = printf("  embedded_data      @ %p, %u bytes (flash .rodata via @embedFile)\n", @as(*const anyopaque, @ptrCast(embedded_data.ptr)), @as(u32, embedded_data.len));

    // --- align ---
    _ = printf("\n[align]\n");

    _ = printf("  dma_buffer  @ %p  align=32  (expect addr & 0x1F == 0)\n", @as(*const anyopaque, @ptrCast(&dma_buffer)));
    _ = printf("  page_buffer @ %p  align=4096 (expect addr & 0xFFF == 0)\n", @as(*const anyopaque, @ptrCast(&page_buffer)));

    const addr_dma = @intFromPtr(&dma_buffer);
    const addr_page = @intFromPtr(&page_buffer);
    _ = printf("  dma_buffer  aligned: %s\n", if (addr_dma & 0x1F == 0) @as([*:0]const u8, "YES") else @as([*:0]const u8, "NO"));
    _ = printf("  page_buffer aligned: %s\n", if (addr_page & 0xFFF == 0) @as([*:0]const u8, "YES") else @as([*:0]const u8, "NO"));

    // --- packed ---
    _ = printf("\n[packed]\n");

    _ = printf("  PacketHeader size: %u bytes (expect 8, not 12)\n", @as(u32, @sizeOf(PacketHeader)));

    const pkt = PacketHeader{ .magic = 0xAB, .length = 1024, .flags = 0x03, .sequence = 42 };
    const pkt_bytes: *const [8]u8 = @ptrCast(&pkt);
    _ = printf("  PacketHeader bytes: %02X %02X %02X %02X %02X %02X %02X %02X\n", pkt_bytes[0], pkt_bytes[1], pkt_bytes[2], pkt_bytes[3], pkt_bytes[4], pkt_bytes[5], pkt_bytes[6], pkt_bytes[7]);

    _ = printf("  RegBits size: %u bytes (expect 1)\n", @as(u32, @sizeOf(RegBits)));
    const reg = RegBits{ .enable = true, .mode = 5 };
    const reg_byte: *const u8 = @ptrCast(&reg);
    _ = printf("  RegBits value: 0x%02X (enable=1, mode=5 => 0b_0000_1011 = 0x0B)\n", reg_byte.*);

    // --- export ---
    _ = printf("\n[export]\n");
    _ = printf("  zig_exported_callback @ %p\n", @as(*const anyopaque, @ptrCast(&zig_exported_callback)));
    zig_exported_callback();

    // --- noinline ---
    _ = printf("\n[noinline]\n");
    const result = noinline_helper(100);
    _ = printf("  noinline_helper(100) = %u\n", result);

    // --- combined: IRAM ISR handler ---
    _ = printf("\n[combined: IRAM + export]\n");
    _ = printf("  iram_isr_handler   @ %p\n", @as(*const anyopaque, @ptrCast(&iram_isr_handler)));
    iram_isr_handler();
    iram_isr_handler();
    iram_isr_handler();
    _ = printf("  iram_counter after 3 calls: %u\n", iram_counter);

    _ = printf("  dma_descriptor     @ %p  align=16 + .dram0.data\n", @as(*const anyopaque, @ptrCast(&dma_descriptor)));

    // --- memory summary ---
    _ = printf("\n[memory]\n");
    _ = printf("  heap free: %u bytes\n", heap.freeHeapSize());

    _ = printf("\n========================================\n");
    _ = printf("  All attribute demos complete.\n");
    _ = printf("========================================\n");

    while (true) {
        freertos.delay(10000);
    }
}
