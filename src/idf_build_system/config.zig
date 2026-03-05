const std = @import("std");
const sdkconfig = @import("idf_sdkconfig");
const config_overrides = @import("utils").config_overrides;

pub const module_name = "idf_build_system";

pub const Config = struct {
    /// Kconfig key: `CONFIG_IDF_CMAKE`.
    /// Controls whether IDF cmake is enabled for the `idf_build_system` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    idf_cmake: bool = true,
    /// Kconfig key: `CONFIG_IDF_EXPERIMENTAL_FEATURES`.
    /// Controls whether IDF experimental features is enabled for the `idf_build_system` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    idf_experimental_features: bool = false,
    /// Kconfig key: `CONFIG_IDF_FIRMWARE_CHIP_ID`.
    /// Sets the literal value for IDF firmware CHIP ID in the `idf_build_system` module; the value is forwarded into ESP-IDF Kconfig output as configured.
    /// Default: `"0x0009"`.
    idf_firmware_chip_id: []const u8 = "0x0009",
    /// Kconfig key: `CONFIG_IDF_INIT_VERSION`.
    /// Sets the literal value for IDF INIT version in the `idf_build_system` module; the value is forwarded into ESP-IDF Kconfig output as configured.
    /// Default: `"5.4.0"`.
    idf_init_version: []const u8 = "5.4.0",
    /// Kconfig key: `CONFIG_IDF_TARGET`.
    /// Sets the literal value for IDF target in the `idf_build_system` module; the value is forwarded into ESP-IDF Kconfig output as configured.
    /// Default: `"esp32s3"`.
    idf_target: []const u8 = "esp32s3",
    /// Kconfig key: `CONFIG_IDF_TARGET_ARCH`.
    /// Sets the literal value for IDF target ARCH in the `idf_build_system` module; the value is forwarded into ESP-IDF Kconfig output as configured.
    /// Default: `"xtensa"`.
    idf_target_arch: []const u8 = "xtensa",
    /// Kconfig key: `CONFIG_IDF_TARGET_ARCH_XTENSA`.
    /// Controls whether IDF target ARCH xtensa is enabled for the `idf_build_system` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    idf_target_arch_xtensa: bool = true,
    /// Kconfig key: `CONFIG_IDF_TARGET_ESP32S3`.
    /// Controls whether IDF target esp32s3 is enabled for the `idf_build_system` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    idf_target_esp32s3: bool = true,
    /// Kconfig key: `CONFIG_IDF_TOOLCHAIN`.
    /// Sets the literal value for IDF toolchain in the `idf_build_system` module; the value is forwarded into ESP-IDF Kconfig output as configured.
    /// Default: `"gcc"`.
    idf_toolchain: []const u8 = "gcc",
    /// Kconfig key: `CONFIG_IDF_TOOLCHAIN_GCC`.
    /// Controls whether IDF toolchain GCC is enabled for the `idf_build_system` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    idf_toolchain_gcc: bool = true,
    /// Kconfig key: `CONFIG_NO_BLOBS`.
    /// Controls whether NO blobs is enabled for the `idf_build_system` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    no_blobs: bool = false,
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
    const entries = try allocator.alloc(sdkconfig.Entry, 11);
    entries[0] = sdkconfig.Entry.flag("CONFIG_IDF_CMAKE", cfg.idf_cmake);
    entries[1] = sdkconfig.Entry.flag("CONFIG_IDF_EXPERIMENTAL_FEATURES", cfg.idf_experimental_features);
    entries[2] = sdkconfig.Entry.raw("CONFIG_IDF_FIRMWARE_CHIP_ID", cfg.idf_firmware_chip_id);
    entries[3] = sdkconfig.Entry.str("CONFIG_IDF_INIT_VERSION", cfg.idf_init_version);
    entries[4] = sdkconfig.Entry.str("CONFIG_IDF_TARGET", cfg.idf_target);
    entries[5] = sdkconfig.Entry.str("CONFIG_IDF_TARGET_ARCH", cfg.idf_target_arch);
    entries[6] = sdkconfig.Entry.flag("CONFIG_IDF_TARGET_ARCH_XTENSA", cfg.idf_target_arch_xtensa);
    entries[7] = sdkconfig.Entry.flag("CONFIG_IDF_TARGET_ESP32S3", cfg.idf_target_esp32s3);
    entries[8] = sdkconfig.Entry.str("CONFIG_IDF_TOOLCHAIN", cfg.idf_toolchain);
    entries[9] = sdkconfig.Entry.flag("CONFIG_IDF_TOOLCHAIN_GCC", cfg.idf_toolchain_gcc);
    entries[10] = sdkconfig.Entry.flag("CONFIG_NO_BLOBS", cfg.no_blobs);

    try docs.append(.{
        .name = module_name,
        .entries = entries,
    });
}
