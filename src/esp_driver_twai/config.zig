const std = @import("std");
const sdkconfig = @import("idf_sdkconfig");
const config_overrides = @import("../utils/config_overrides.zig");

pub const module_name = "esp_driver_twai";

pub const Config = struct {
    /// Kconfig key: `CONFIG_TWAI_ERRATA_FIX_LISTEN_ONLY_DOM`.
    /// Controls whether TWAI errata FIX listen ONLY DOM is enabled for the `esp_driver_twai` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    twai_errata_fix_listen_only_dom: bool = true,
    /// Kconfig key: `CONFIG_TWAI_ISR_IN_IRAM`.
    /// Controls whether TWAI ISR IN IRAM is enabled for the `esp_driver_twai` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    twai_isr_in_iram: bool = false,
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
    entries[0] = sdkconfig.Entry.flag("CONFIG_TWAI_ERRATA_FIX_LISTEN_ONLY_DOM", cfg.twai_errata_fix_listen_only_dom);
    entries[1] = sdkconfig.Entry.flag("CONFIG_TWAI_ISR_IN_IRAM", cfg.twai_isr_in_iram);

    try docs.append(.{
        .name = module_name,
        .entries = entries,
    });
}
