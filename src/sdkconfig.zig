const std = @import("std");

pub const schema = @import("idf_sdkconfig");
pub const esp_system_config = @import("esp_system/config.zig");
pub const freertos_config = @import("freertos/config.zig");
pub const app_metadata_config = @import("app_metadata/config.zig");
pub const app_trace_config = @import("app_trace/config.zig");
pub const bootloader_config = @import("bootloader/config.zig");
pub const bt_config = @import("bt/config.zig");
pub const console_config = @import("console/config.zig");
pub const efuse_config = @import("efuse/config.zig");
pub const esp_adc_config = @import("esp_adc/config.zig");
pub const esp_coex_config = @import("esp_coex/config.zig");
pub const esp_driver_gdma_config = @import("esp_driver_gdma/config.zig");
pub const esp_driver_gpio_config = @import("esp_driver_gpio/config.zig");
pub const esp_driver_gptimer_config = @import("esp_driver_gptimer/config.zig");
pub const esp_driver_i2c_config = @import("esp_driver_i2c/config.zig");
pub const esp_driver_i2s_config = @import("esp_driver_i2s/config.zig");
pub const esp_driver_ledc_config = @import("esp_driver_ledc/config.zig");
pub const esp_driver_mcpwm_config = @import("esp_driver_mcpwm/config.zig");
pub const esp_driver_pcnt_config = @import("esp_driver_pcnt/config.zig");
pub const esp_driver_rmt_config = @import("esp_driver_rmt/config.zig");
pub const esp_driver_sdm_config = @import("esp_driver_sdm/config.zig");
pub const esp_driver_spi_config = @import("esp_driver_spi/config.zig");
pub const esp_driver_touch_sens_config = @import("esp_driver_touch_sens/config.zig");
pub const esp_driver_tsens_config = @import("esp_driver_tsens/config.zig");
pub const esp_driver_twai_config = @import("esp_driver_twai/config.zig");
pub const esp_driver_uart_config = @import("esp_driver_uart/config.zig");
pub const esp_eth_config = @import("esp_eth/config.zig");
pub const esp_event_config = @import("esp_event/config.zig");
pub const esp_gdbstub_config = @import("esp_gdbstub/config.zig");
pub const esp_http_client_config = @import("esp_http_client/config.zig");
pub const esp_http_server_config = @import("esp_http_server/config.zig");
pub const esp_https_ota_config = @import("esp_https_ota/config.zig");
pub const esp_https_server_config = @import("esp_https_server/config.zig");
pub const esp_hw_support_config = @import("esp_hw_support/config.zig");
pub const esp_lcd_config = @import("esp_lcd/config.zig");
pub const esp_misc_config = @import("esp_misc/config.zig");
pub const esp_mm_config = @import("esp_mm/config.zig");
pub const esp_netif_config = @import("esp_netif/config.zig");
pub const esp_phy_config = @import("esp_phy/config.zig");
pub const esp_pm_config = @import("esp_pm/config.zig");
pub const esp_psram_config = @import("esp_psram/config.zig");
pub const esp_security_config = @import("esp_security/config.zig");
pub const esp_timer_config = @import("esp_timer/config.zig");
pub const esp_wifi_config = @import("esp_wifi/config.zig");
pub const espcoredump_config = @import("espcoredump/config.zig");
pub const esptool_py_config = @import("esptool_py/config.zig");
pub const fatfs_config = @import("fatfs/config.zig");
pub const hal_config = @import("hal/config.zig");
pub const heap_config = @import("heap/config.zig");
pub const idf_build_system_config = @import("idf_build_system/config.zig");
pub const log_config = @import("log/config.zig");
pub const lwip_config = @import("lwip/config.zig");
pub const mbedtls_config = @import("mbedtls/config.zig");
pub const mqtt_config = @import("mqtt/config.zig");
pub const newlib_config = @import("newlib/config.zig");
pub const nvs_flash_config = @import("nvs_flash/config.zig");
pub const openthread_config = @import("openthread/config.zig");
pub const partition_table_config = @import("partition_table/config.zig");
pub const pthread_config = @import("pthread/config.zig");
pub const soc_config = @import("soc/config.zig");
pub const spi_flash_config = @import("spi_flash/config.zig");
pub const spiffs_config = @import("spiffs/config.zig");
pub const target_soc_config = @import("target_soc/config.zig");
pub const tcp_transport_config = @import("tcp_transport/config.zig");
pub const toolchain_config = @import("toolchain/config.zig");
pub const ulp_config = @import("ulp/config.zig");
pub const unity_config = @import("unity/config.zig");
pub const usb_config = @import("usb/config.zig");
pub const vfs_config = @import("vfs/config.zig");
pub const wear_levelling_config = @import("wear_levelling/config.zig");
pub const wpa_supplicant_config = @import("wpa_supplicant/config.zig");

pub const ModuleBinding = struct {
    field_name: []const u8,
    module: type,
};

pub const all_bindings = [_]ModuleBinding{
    .{ .field_name = "core", .module = esp_system_config },
    .{ .field_name = "freertos", .module = freertos_config },
    .{ .field_name = "app_metadata", .module = app_metadata_config },
    .{ .field_name = "app_trace", .module = app_trace_config },
    .{ .field_name = "bootloader", .module = bootloader_config },
    .{ .field_name = "bt", .module = bt_config },
    .{ .field_name = "console", .module = console_config },
    .{ .field_name = "efuse", .module = efuse_config },
    .{ .field_name = "esp_adc", .module = esp_adc_config },
    .{ .field_name = "esp_coex", .module = esp_coex_config },
    .{ .field_name = "esp_driver_gdma", .module = esp_driver_gdma_config },
    .{ .field_name = "esp_driver_gpio", .module = esp_driver_gpio_config },
    .{ .field_name = "esp_driver_gptimer", .module = esp_driver_gptimer_config },
    .{ .field_name = "esp_driver_i2c", .module = esp_driver_i2c_config },
    .{ .field_name = "esp_driver_i2s", .module = esp_driver_i2s_config },
    .{ .field_name = "esp_driver_ledc", .module = esp_driver_ledc_config },
    .{ .field_name = "esp_driver_mcpwm", .module = esp_driver_mcpwm_config },
    .{ .field_name = "esp_driver_pcnt", .module = esp_driver_pcnt_config },
    .{ .field_name = "esp_driver_rmt", .module = esp_driver_rmt_config },
    .{ .field_name = "esp_driver_sdm", .module = esp_driver_sdm_config },
    .{ .field_name = "esp_driver_spi", .module = esp_driver_spi_config },
    .{ .field_name = "esp_driver_touch_sens", .module = esp_driver_touch_sens_config },
    .{ .field_name = "esp_driver_tsens", .module = esp_driver_tsens_config },
    .{ .field_name = "esp_driver_twai", .module = esp_driver_twai_config },
    .{ .field_name = "esp_driver_uart", .module = esp_driver_uart_config },
    .{ .field_name = "esp_eth", .module = esp_eth_config },
    .{ .field_name = "esp_event", .module = esp_event_config },
    .{ .field_name = "esp_gdbstub", .module = esp_gdbstub_config },
    .{ .field_name = "esp_http_client", .module = esp_http_client_config },
    .{ .field_name = "esp_http_server", .module = esp_http_server_config },
    .{ .field_name = "esp_https_ota", .module = esp_https_ota_config },
    .{ .field_name = "esp_https_server", .module = esp_https_server_config },
    .{ .field_name = "esp_hw_support", .module = esp_hw_support_config },
    .{ .field_name = "esp_lcd", .module = esp_lcd_config },
    .{ .field_name = "esp_misc", .module = esp_misc_config },
    .{ .field_name = "esp_mm", .module = esp_mm_config },
    .{ .field_name = "esp_netif", .module = esp_netif_config },
    .{ .field_name = "esp_phy", .module = esp_phy_config },
    .{ .field_name = "esp_pm", .module = esp_pm_config },
    .{ .field_name = "esp_psram", .module = esp_psram_config },
    .{ .field_name = "esp_security", .module = esp_security_config },
    .{ .field_name = "esp_timer", .module = esp_timer_config },
    .{ .field_name = "esp_wifi", .module = esp_wifi_config },
    .{ .field_name = "espcoredump", .module = espcoredump_config },
    .{ .field_name = "esptool_py", .module = esptool_py_config },
    .{ .field_name = "fatfs", .module = fatfs_config },
    .{ .field_name = "hal", .module = hal_config },
    .{ .field_name = "heap", .module = heap_config },
    .{ .field_name = "idf_build_system", .module = idf_build_system_config },
    .{ .field_name = "log", .module = log_config },
    .{ .field_name = "lwip", .module = lwip_config },
    .{ .field_name = "mbedtls", .module = mbedtls_config },
    .{ .field_name = "mqtt", .module = mqtt_config },
    .{ .field_name = "newlib", .module = newlib_config },
    .{ .field_name = "nvs_flash", .module = nvs_flash_config },
    .{ .field_name = "openthread", .module = openthread_config },
    .{ .field_name = "partition_table_cfg", .module = partition_table_config },
    .{ .field_name = "pthread", .module = pthread_config },
    .{ .field_name = "soc", .module = soc_config },
    .{ .field_name = "spi_flash", .module = spi_flash_config },
    .{ .field_name = "spiffs", .module = spiffs_config },
    .{ .field_name = "target_soc", .module = target_soc_config },
    .{ .field_name = "tcp_transport", .module = tcp_transport_config },
    .{ .field_name = "toolchain", .module = toolchain_config },
    .{ .field_name = "ulp", .module = ulp_config },
    .{ .field_name = "unity", .module = unity_config },
    .{ .field_name = "usb", .module = usb_config },
    .{ .field_name = "vfs", .module = vfs_config },
    .{ .field_name = "wear_levelling", .module = wear_levelling_config },
    .{ .field_name = "wpa_supplicant", .module = wpa_supplicant_config },
};

pub const required_bindings = all_bindings;

pub fn ensureRequiredModuleConfig(comptime ConfigType: type) void {
    ensureAllModuleConfig(ConfigType);
}

pub fn ensureAllModuleConfig(comptime ConfigType: type) void {
    inline for (all_bindings) |binding| {
        ensureConfigField(ConfigType, binding.field_name, binding.module);
    }
}

pub fn ensureConfigField(comptime ConfigType: type, comptime field_name: []const u8, comptime module: type) void {
    if (!@hasDecl(module, "Config")) {
        @compileError(std.fmt.comptimePrint(
            "module {s} must export Config",
            .{@typeName(module)},
        ));
    }

    if (!@hasDecl(module, "appendModuleDoc")) {
        @compileError(std.fmt.comptimePrint(
            "module {s} must export appendModuleDoc",
            .{@typeName(module)},
        ));
    }

    if (!@hasField(ConfigType, field_name)) {
        @compileError(std.fmt.comptimePrint(
            "board Config is missing required field '{s}' for module {s}",
            .{ field_name, @typeName(module) },
        ));
    }

    const field_type = @FieldType(ConfigType, field_name);
    if (field_type != module.Config) {
        @compileError(std.fmt.comptimePrint(
            "board Config field '{s}' type mismatch: expected {s}, found {s}",
            .{ field_name, @typeName(module.Config), @typeName(field_type) },
        ));
    }
}

pub fn appendModuleDocFromConfig(
    comptime ConfigType: type,
    comptime field_name: []const u8,
    comptime module: type,
    allocator: std.mem.Allocator,
    docs: *std.array_list.Managed(schema.ModuleDoc),
    cfg: anytype,
) std.mem.Allocator.Error!void {
    comptime ensureConfigField(ConfigType, field_name, module);
    try module.appendModuleDoc(allocator, docs, @field(cfg, field_name));
}

pub fn appendRequiredModuleDocs(
    comptime ConfigType: type,
    allocator: std.mem.Allocator,
    docs: *std.array_list.Managed(schema.ModuleDoc),
    cfg: anytype,
) std.mem.Allocator.Error!void {
    try appendAllModuleDocs(ConfigType, allocator, docs, cfg);
}

pub fn appendAllModuleDocs(
    comptime ConfigType: type,
    allocator: std.mem.Allocator,
    docs: *std.array_list.Managed(schema.ModuleDoc),
    cfg: anytype,
) std.mem.Allocator.Error!void {
    try appendAllModuleDocsSkippingFields(ConfigType, &.{}, allocator, docs, cfg);
}

pub fn appendAllModuleDocsExceptField(
    comptime ConfigType: type,
    comptime skip_field_name: []const u8,
    allocator: std.mem.Allocator,
    docs: *std.array_list.Managed(schema.ModuleDoc),
    cfg: anytype,
) std.mem.Allocator.Error!void {
    try appendAllModuleDocsSkippingFields(ConfigType, &.{skip_field_name}, allocator, docs, cfg);
}

pub fn appendAllModuleDocsSkippingFields(
    comptime ConfigType: type,
    comptime skip_field_names: []const []const u8,
    allocator: std.mem.Allocator,
    docs: *std.array_list.Managed(schema.ModuleDoc),
    cfg: anytype,
) std.mem.Allocator.Error!void {
    inline for (all_bindings) |binding| {
        if (comptime shouldSkipField(binding.field_name, skip_field_names)) continue;
        try appendModuleDocFromConfig(
            ConfigType,
            binding.field_name,
            binding.module,
            allocator,
            docs,
            cfg,
        );
    }
}

fn shouldSkipField(
    comptime field_name: []const u8,
    comptime skip_field_names: []const []const u8,
) bool {
    inline for (skip_field_names) |skip| {
        if (comptime std.mem.eql(u8, field_name, skip)) return true;
    }
    return false;
}
