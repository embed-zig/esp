const std = @import("std");
const sdkconfig = @import("../../idf/sdkconfig/idf_mod.zig");
const config_overrides = sdkconfig.config_overrides;

pub const module_name = "app_metadata";

pub const Config = struct {
    /// Kconfig key: `CONFIG_APP_BUILD_BOOTLOADER`.
    /// Controls whether APP build bootloader is enabled for the `app_metadata` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    app_build_bootloader: bool = true,
    /// Kconfig key: `CONFIG_APP_BUILD_GENERATE_BINARIES`.
    /// Controls whether APP build generate binaries is enabled for the `app_metadata` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    app_build_generate_binaries: bool = true,
    /// Kconfig key: `CONFIG_APP_BUILD_TYPE_APP_2NDBOOT`.
    /// Controls whether APP build TYPE APP 2ndboot is enabled for the `app_metadata` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    app_build_type_app_2ndboot: bool = true,
    /// Kconfig key: `CONFIG_APP_BUILD_TYPE_ELF_RAM`.
    /// Controls whether APP build TYPE ELF RAM is enabled for the `app_metadata` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    app_build_type_elf_ram: bool = false,
    /// Kconfig key: `CONFIG_APP_BUILD_TYPE_RAM`.
    /// Controls whether APP build TYPE RAM is enabled for the `app_metadata` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    app_build_type_ram: bool = false,
    /// Kconfig key: `CONFIG_APP_BUILD_USE_FLASH_SECTIONS`.
    /// Controls whether APP build USE flash sections is enabled for the `app_metadata` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    app_build_use_flash_sections: bool = true,
    /// Kconfig key: `CONFIG_APP_COMPILE_TIME_DATE`.
    /// Controls whether APP compile TIME DATE is enabled for the `app_metadata` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    app_compile_time_date: bool = true,
    /// Kconfig key: `CONFIG_APP_EXCLUDE_PROJECT_NAME_VAR`.
    /// Controls whether APP exclude project NAME VAR is enabled for the `app_metadata` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    app_exclude_project_name_var: bool = false,
    /// Kconfig key: `CONFIG_APP_EXCLUDE_PROJECT_VER_VAR`.
    /// Controls whether APP exclude project VER VAR is enabled for the `app_metadata` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    app_exclude_project_ver_var: bool = false,
    /// Kconfig key: `CONFIG_APP_NO_BLOBS`.
    /// Controls whether APP NO blobs is enabled for the `app_metadata` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    app_no_blobs: bool = false,
    /// Kconfig key: `CONFIG_APP_PROJECT_VER_FROM_CONFIG`.
    /// Controls whether APP project VER FROM config is enabled for the `app_metadata` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    app_project_ver_from_config: bool = false,
    /// Kconfig key: `CONFIG_APP_REPRODUCIBLE_BUILD`.
    /// Controls whether APP reproducible build is enabled for the `app_metadata` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    app_reproducible_build: bool = false,
    /// Kconfig key: `CONFIG_APP_RETRIEVE_LEN_ELF_SHA`.
    /// Sets the numeric value for APP retrieve LEN ELF SHA in the `app_metadata` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `9`.
    app_retrieve_len_elf_sha: i64 = 9,
    /// Kconfig key: `CONFIG_APP_ROLLBACK_ENABLE`.
    /// Controls whether APP rollback enable is enabled for the `app_metadata` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    app_rollback_enable: bool = false,

    pub const default: Config = .{};

    pub fn withDefaultConfig(overrides: anytype) Config {
        return config_overrides.withDefaultConfig(Config, overrides);
    }

    pub fn appendModuleDoc(
        allocator: std.mem.Allocator,
        docs: *std.array_list.Managed(sdkconfig.ModuleDoc),
        cfg: Config,
    ) std.mem.Allocator.Error!void {
        const entries = try allocator.alloc(sdkconfig.Entry, 14);
        entries[0] = sdkconfig.Entry.flag("CONFIG_APP_BUILD_BOOTLOADER", cfg.app_build_bootloader);
        entries[1] = sdkconfig.Entry.flag("CONFIG_APP_BUILD_GENERATE_BINARIES", cfg.app_build_generate_binaries);
        entries[2] = sdkconfig.Entry.flag("CONFIG_APP_BUILD_TYPE_APP_2NDBOOT", cfg.app_build_type_app_2ndboot);
        entries[3] = sdkconfig.Entry.flag("CONFIG_APP_BUILD_TYPE_ELF_RAM", cfg.app_build_type_elf_ram);
        entries[4] = sdkconfig.Entry.flag("CONFIG_APP_BUILD_TYPE_RAM", cfg.app_build_type_ram);
        entries[5] = sdkconfig.Entry.flag("CONFIG_APP_BUILD_USE_FLASH_SECTIONS", cfg.app_build_use_flash_sections);
        entries[6] = sdkconfig.Entry.flag("CONFIG_APP_COMPILE_TIME_DATE", cfg.app_compile_time_date);
        entries[7] = sdkconfig.Entry.flag("CONFIG_APP_EXCLUDE_PROJECT_NAME_VAR", cfg.app_exclude_project_name_var);
        entries[8] = sdkconfig.Entry.flag("CONFIG_APP_EXCLUDE_PROJECT_VER_VAR", cfg.app_exclude_project_ver_var);
        entries[9] = sdkconfig.Entry.flag("CONFIG_APP_NO_BLOBS", cfg.app_no_blobs);
        entries[10] = sdkconfig.Entry.flag("CONFIG_APP_PROJECT_VER_FROM_CONFIG", cfg.app_project_ver_from_config);
        entries[11] = sdkconfig.Entry.flag("CONFIG_APP_REPRODUCIBLE_BUILD", cfg.app_reproducible_build);
        entries[12] = sdkconfig.Entry.int("CONFIG_APP_RETRIEVE_LEN_ELF_SHA", cfg.app_retrieve_len_elf_sha);
        entries[13] = sdkconfig.Entry.flag("CONFIG_APP_ROLLBACK_ENABLE", cfg.app_rollback_enable);

        try docs.append(.{
            .name = module_name,
            .entries = entries,
        });
    }
};
