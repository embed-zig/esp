const std = @import("std");
const sdkconfig = @import("idf_sdkconfig");
const config_overrides = @import("utils").config_overrides;

pub const module_name = "esp_driver_gpio";

pub const Config = struct {
    /// Kconfig key: `CONFIG_GPIO_CTRL_FUNC_IN_IRAM`.
    /// Controls whether GPIO CTRL FUNC IN IRAM is enabled for the `esp_driver_gpio` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    gpio_ctrl_func_in_iram: bool = false,
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
    const entries = try allocator.alloc(sdkconfig.Entry, 1);
    entries[0] = sdkconfig.Entry.flag("CONFIG_GPIO_CTRL_FUNC_IN_IRAM", cfg.gpio_ctrl_func_in_iram);

    try docs.append(.{
        .name = module_name,
        .entries = entries,
    });
}
