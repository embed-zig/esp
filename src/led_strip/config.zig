const std = @import("std");
const sdkconfig = @import("idf_sdkconfig");
const config_overrides = @import("../utils/config_overrides.zig");

pub const module_name = "led_strip";

pub const Config = struct {
    /// Kconfig key: `CONFIG_SOC_RMT_SUPPORTED`.
    /// SOC-level flag indicating whether the RMT peripheral is available on the
    /// target chip. When true, the RMT backend for LED strip is compiled in.
    /// This is a chip capability, not a user-settable option.
    /// Default: `true` (most ESP32 variants support RMT).
    soc_rmt_supported: bool = true,

    /// Kconfig key: `CONFIG_SOC_GPSPI_SUPPORTED`.
    /// SOC-level flag indicating whether the General Purpose SPI peripheral is
    /// available on the target chip. When true, the SPI backend for LED strip
    /// is compiled in (requires IDF >= 5.1).
    /// This is a chip capability, not a user-settable option.
    /// Default: `true` (most ESP32 variants support GPSPI).
    soc_gpspi_supported: bool = true,
};

pub const default: Config = .{};

pub fn withDefaultConfig(overrides: anytype) Config {
    return config_overrides.withDefaultConfig(Config, overrides);
}

pub fn appendModuleDoc(
    allocator: std.mem.Allocator,
    docs: *std.array_list.Managed(sdkconfig.ModuleDoc),
    cfg: Config,
) std.mem.Allocator.Error!void {
    const entries = try allocator.alloc(sdkconfig.Entry, 2);
    entries[0] = sdkconfig.Entry.flag("CONFIG_SOC_RMT_SUPPORTED", cfg.soc_rmt_supported);
    entries[1] = sdkconfig.Entry.flag("CONFIG_SOC_GPSPI_SUPPORTED", cfg.soc_gpspi_supported);

    try docs.append(.{
        .name = module_name,
        .entries = entries,
    });
}
