const std = @import("std");
const sdkconfig = @import("idf_sdkconfig");
const config_overrides = @import("utils").config_overrides;

pub const module_name = "esp_driver_gdma";

pub const Config = struct {
    /// Kconfig key: `CONFIG_GDMA_CTRL_FUNC_IN_IRAM`.
    /// Controls whether GDMA CTRL FUNC IN IRAM is enabled for the `esp_driver_gdma` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    gdma_ctrl_func_in_iram: bool = true,
    /// Kconfig key: `CONFIG_GDMA_ENABLE_DEBUG_LOG`.
    /// Controls whether GDMA enable debug LOG is enabled for the `esp_driver_gdma` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    gdma_enable_debug_log: bool = false,
    /// Kconfig key: `CONFIG_GDMA_ISR_IRAM_SAFE`.
    /// Controls whether GDMA ISR IRAM SAFE is enabled for the `esp_driver_gdma` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    gdma_isr_iram_safe: bool = false,
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
    const entries = try allocator.alloc(sdkconfig.Entry, 3);
    entries[0] = sdkconfig.Entry.flag("CONFIG_GDMA_CTRL_FUNC_IN_IRAM", cfg.gdma_ctrl_func_in_iram);
    entries[1] = sdkconfig.Entry.flag("CONFIG_GDMA_ENABLE_DEBUG_LOG", cfg.gdma_enable_debug_log);
    entries[2] = sdkconfig.Entry.flag("CONFIG_GDMA_ISR_IRAM_SAFE", cfg.gdma_isr_iram_safe);

    try docs.append(.{
        .name = module_name,
        .entries = entries,
    });
}
