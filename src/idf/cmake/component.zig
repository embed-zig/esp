pub const Entry = struct {
    module_name: []const u8,
    idf_requires: []const []const u8,
    embedded_files: []const EmbeddedFile,
    sdkconfig_guard: ?[]const u8 = null,
    idf_external_components: []const ExternalComponent = &.{},
};

pub const EmbeddedFile = struct {
    path: []const u8,
    content: []const u8,
};

pub const ExternalComponent = struct {
    name: []const u8,
    version: []const u8,
};

fn entryFrom(comptime mod: type) Entry {
    const files: []const EmbeddedFile = if (@hasDecl(mod, "embedded_files")) mod.embedded_files else &.{};
    const externals: []const ExternalComponent = if (@hasDecl(mod, "idf_external_components")) mod.idf_external_components else &.{};
    return .{
        .module_name = mod.module_name,
        .idf_requires = if (@hasDecl(mod, "idf_requires")) mod.idf_requires else &.{},
        .embedded_files = files,
        .sdkconfig_guard = if (@hasDecl(mod, "sdkconfig_guard")) mod.sdkconfig_guard else null,
        .idf_external_components = externals,
    };
}

pub const modules = [_]Entry{
    entryFrom(@import("../../component/esp_lcd/idf_mod.zig")),
    entryFrom(@import("../../component/esp_driver_gpio/idf_mod.zig")),
    entryFrom(@import("../../component/esp_driver_i2c/idf_mod.zig")),
    entryFrom(@import("../../component/esp_driver_spi/idf_mod.zig")),
    entryFrom(@import("../../component/esp_driver_i2s/idf_mod.zig")),
    entryFrom(@import("../../component/esp_driver_ledc/idf_mod.zig")),
    entryFrom(@import("../../component/esp_adc/idf_mod.zig")),
    entryFrom(@import("../../component/esp_wifi/idf_mod.zig")),
    entryFrom(@import("../../component/bt/idf_mod.zig")),
    entryFrom(@import("../../component/freertos/idf_mod.zig")),
    entryFrom(@import("../../component/esp_timer/idf_mod.zig")),
    entryFrom(@import("../../component/esp_cpu/idf_mod.zig")),
    entryFrom(@import("../../component/esp_random/idf_mod.zig")),
    entryFrom(@import("../../component/esp_rom/idf_mod.zig")),
    entryFrom(@import("../../component/newlib/idf_mod.zig")),
    entryFrom(@import("../../component/nvs_flash/idf_mod.zig")),
    entryFrom(@import("../../component/app_metadata/idf_mod.zig")),
    entryFrom(@import("../../component/heap/idf_mod.zig")),
    entryFrom(@import("../../component/led_strip/idf_mod.zig")),
    entryFrom(@import("../../component/esp_sr/idf_mod.zig")),
    entryFrom(@import("../../component/lwip/idf_mod.zig")),
    entryFrom(@import("../../component/esp_netif/idf_mod.zig")),
    entryFrom(@import("../../component/mbedtls/idf_mod.zig")),
    entryFrom(@import("../../component/esp_driver_uart/idf_mod.zig")),
    entryFrom(@import("../../component/spiffs/idf_mod.zig")),
};
