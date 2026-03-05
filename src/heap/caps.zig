/// Memory capability flags for ESP-IDF heap allocation.
///
/// These map 1:1 to ESP-IDF `MALLOC_CAP_*` defines. The actual values are
/// chip-dependent, so they are obtained at runtime via thin C shims.
///
/// Flags can be combined with `combine()` to express multiple requirements.
/// When combined, the allocator returns memory that satisfies **all** of the
/// requested capabilities simultaneously. For example:
///
/// ```
/// // Memory that is both DMA-capable and in internal SRAM
/// const caps = Caps.dma().combine(Caps.internal());
///
/// // Memory in external PSRAM, byte-addressable
/// const caps = Caps.spiram().combine(Caps.@"8bit"());
/// ```
///
/// Not all combinations are valid — requesting contradictory regions
/// (e.g. `spiram().combine(internal())`) will cause allocation to fail at
/// runtime because no memory can satisfy both constraints.
pub const Caps = struct {
    raw: u32,

    const cap_defs = .{
        .{ "exec", "Executable memory (IRAM). For code that must run from RAM (e.g. ISR handlers, performance-critical routines)." },
        .{ "32bit", "32-bit aligned memory. Allows the allocator to also use IRAM, which is unavailable to normal `malloc()`. Data must be accessed via 32-bit reads/writes only; byte access will fault." },
        .{ "8bit", "Byte-addressable memory (DRAM). This is what standard `malloc()` uses internally. All DRAM heaps have this capability." },
        .{ "dma", "DMA-capable memory. Required for buffers used with hardware DMA engines (SPI, I2S, etc.). Excludes external PSRAM by default." },
        .{ "spiram", "External SPI RAM (PSRAM). Only available when PSRAM is enabled in sdkconfig and physically present." },
        .{ "internal", "Internal SRAM only (excludes PSRAM). Use when you need guaranteed low-latency access or the peripheral cannot reach external memory." },
        .{ "default", "Default capability — equivalent to what `malloc()` returns. Byte-addressable memory from the most appropriate region." },
        .{ "iram_8bit", "Byte-addressable IRAM. On chips where IRAM supports 8-bit access (e.g. ESP32-S3), this allows using IRAM as general data memory." },
        .{ "retention", "Memory that is retained during light-sleep. Use for data that must survive power-management sleep cycles." },
        .{ "rtc", "RTC fast memory. Retained during deep-sleep (with RTC memory powered). Available on chips with RTC RAM; returns 0 on chips without it." },
    };

    fn externCapFn(comptime name: []const u8) *const fn () callconv(.c) u32 {
        const sym = "espz_heap_cap_" ++ name;
        return @extern(*const fn () callconv(.c) u32, .{ .name = sym });
    }

    fn capFn(comptime name: []const u8) fn () Caps {
        return struct {
            fn f() Caps {
                return .{ .raw = externCapFn(name)() };
            }
        }.f;
    }

    pub const exec = capFn("exec");
    pub const @"32bit" = capFn("32bit");
    pub const @"8bit" = capFn("8bit");
    pub const dma = capFn("dma");
    pub const spiram = capFn("spiram");
    pub const internal = capFn("internal");
    pub const default = capFn("default");
    pub const iram_8bit = capFn("iram_8bit");
    pub const retention = capFn("retention");
    pub const rtc = capFn("rtc");

    pub fn fromRaw(raw: u32) Caps {
        return .{ .raw = raw };
    }

    /// Combine two capability sets (bitwise OR). The allocator will
    /// return memory satisfying **all** requested capabilities.
    pub fn combine(a: Caps, b: Caps) Caps {
        return .{ .raw = a.raw | b.raw };
    }

    /// Shorthand: `spiram | 8bit` — byte-addressable PSRAM.
    pub fn defaultPsram() Caps {
        return spiram().combine(@"8bit"());
    }

    /// Shorthand: `internal | 8bit` — byte-addressable internal SRAM.
    pub fn defaultInternal() Caps {
        return internal().combine(@"8bit"());
    }
};
