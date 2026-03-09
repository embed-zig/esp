const std = @import("std");
const sdkconfig = @import("../../idf/sdkconfig/idf_mod.zig");
const config_overrides = sdkconfig.config_overrides;

pub const module_name = "toolchain";

pub const Config = struct {
    /// Kconfig key: `CONFIG_COMPILER_ASSERT_NDEBUG_EVALUATE`.
    /// Controls whether compiler assert ndebug evaluate is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    compiler_assert_ndebug_evaluate: bool = true,
    /// Kconfig key: `CONFIG_COMPILER_CXX_EXCEPTIONS`.
    /// Controls whether compiler CXX exceptions is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_cxx_exceptions: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_CXX_RTTI`.
    /// Controls whether compiler CXX RTTI is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_cxx_rtti: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_DISABLE_DEFAULT_ERRORS`.
    /// Controls whether compiler disable default errors is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    compiler_disable_default_errors: bool = true,
    /// Kconfig key: `CONFIG_COMPILER_DISABLE_GCC12_WARNINGS`.
    /// Controls whether compiler disable gcc12 warnings is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_disable_gcc12_warnings: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_DISABLE_GCC13_WARNINGS`.
    /// Controls whether compiler disable gcc13 warnings is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_disable_gcc13_warnings: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_DISABLE_GCC14_WARNINGS`.
    /// Controls whether compiler disable gcc14 warnings is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_disable_gcc14_warnings: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_DUMP_RTL_FILES`.
    /// Controls whether compiler DUMP RTL files is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_dump_rtl_files: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_FLOAT_LIB_FROM_GCCLIB`.
    /// Controls whether compiler float LIB FROM gcclib is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    compiler_float_lib_from_gcclib: bool = true,
    /// Kconfig key: `CONFIG_COMPILER_HIDE_PATHS_MACROS`.
    /// Controls whether compiler HIDE paths macros is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    compiler_hide_paths_macros: bool = true,
    /// Kconfig key: `CONFIG_COMPILER_NO_MERGE_CONSTANTS`.
    /// Controls whether compiler NO merge constants is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_no_merge_constants: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_OPTIMIZATION_ASSERTIONS_DISABLE`.
    /// Controls whether compiler optimization assertions disable is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_optimization_assertions_disable: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_OPTIMIZATION_ASSERTIONS_ENABLE`.
    /// Controls whether compiler optimization assertions enable is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    compiler_optimization_assertions_enable: bool = true,
    /// Kconfig key: `CONFIG_COMPILER_OPTIMIZATION_ASSERTIONS_SILENT`.
    /// Controls whether compiler optimization assertions silent is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_optimization_assertions_silent: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_OPTIMIZATION_ASSERTION_LEVEL`.
    /// Sets the numeric value for compiler optimization assertion level in the `toolchain` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `2`.
    compiler_optimization_assertion_level: i64 = 2,
    /// Kconfig key: `CONFIG_COMPILER_OPTIMIZATION_CHECKS_SILENT`.
    /// Controls whether compiler optimization checks silent is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_optimization_checks_silent: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_OPTIMIZATION_DEBUG`.
    /// Controls whether compiler optimization debug is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    compiler_optimization_debug: bool = true,
    /// Kconfig key: `CONFIG_COMPILER_OPTIMIZATION_DEFAULT`.
    /// Controls whether compiler optimization default is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    compiler_optimization_default: bool = true,
    /// Kconfig key: `CONFIG_COMPILER_OPTIMIZATION_LEVEL_DEBUG`.
    /// Controls whether compiler optimization level debug is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    compiler_optimization_level_debug: bool = true,
    /// Kconfig key: `CONFIG_COMPILER_OPTIMIZATION_LEVEL_RELEASE`.
    /// Controls whether compiler optimization level release is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_optimization_level_release: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_OPTIMIZATION_NONE`.
    /// Controls whether compiler optimization NONE is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_optimization_none: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_OPTIMIZATION_PERF`.
    /// Controls whether compiler optimization PERF is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_optimization_perf: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_OPTIMIZATION_SIZE`.
    /// Controls whether compiler optimization SIZE is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_optimization_size: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_ORPHAN_SECTIONS_PLACE`.
    /// Controls whether compiler orphan sections place is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_orphan_sections_place: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_ORPHAN_SECTIONS_WARNING`.
    /// Controls whether compiler orphan sections warning is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    compiler_orphan_sections_warning: bool = true,
    /// Kconfig key: `CONFIG_COMPILER_RT_LIB_GCCLIB`.
    /// Controls whether compiler RT LIB gcclib is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    compiler_rt_lib_gcclib: bool = true,
    /// Kconfig key: `CONFIG_COMPILER_RT_LIB_NAME`.
    /// Sets the literal value for compiler RT LIB NAME in the `toolchain` module; the value is forwarded into ESP-IDF Kconfig output as configured.
    /// Default: `"gcc"`.
    compiler_rt_lib_name: []const u8 = "gcc",
    /// Kconfig key: `CONFIG_COMPILER_STACK_CHECK_MODE_ALL`.
    /// Controls whether compiler stack check MODE ALL is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_stack_check_mode_all: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_STACK_CHECK_MODE_NONE`.
    /// Controls whether compiler stack check MODE NONE is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    compiler_stack_check_mode_none: bool = true,
    /// Kconfig key: `CONFIG_COMPILER_STACK_CHECK_MODE_NORM`.
    /// Controls whether compiler stack check MODE NORM is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_stack_check_mode_norm: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_STACK_CHECK_MODE_STRONG`.
    /// Controls whether compiler stack check MODE strong is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_stack_check_mode_strong: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_STATIC_ANALYZER`.
    /// Controls whether compiler static analyzer is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_static_analyzer: bool = false,
    /// Kconfig key: `CONFIG_COMPILER_WARN_WRITE_STRINGS`.
    /// Controls whether compiler WARN write strings is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    compiler_warn_write_strings: bool = false,
    /// Kconfig key: `CONFIG_CXX_EXCEPTIONS`.
    /// Controls whether CXX exceptions is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    cxx_exceptions: bool = false,
    /// Kconfig key: `CONFIG_OPTIMIZATION_ASSERTIONS_DISABLED`.
    /// Controls whether optimization assertions disabled is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    optimization_assertions_disabled: bool = false,
    /// Kconfig key: `CONFIG_OPTIMIZATION_ASSERTIONS_ENABLED`.
    /// Controls whether optimization assertions enabled is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    optimization_assertions_enabled: bool = true,
    /// Kconfig key: `CONFIG_OPTIMIZATION_ASSERTIONS_SILENT`.
    /// Controls whether optimization assertions silent is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    optimization_assertions_silent: bool = false,
    /// Kconfig key: `CONFIG_OPTIMIZATION_ASSERTION_LEVEL`.
    /// Sets the numeric value for optimization assertion level in the `toolchain` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `2`.
    optimization_assertion_level: i64 = 2,
    /// Kconfig key: `CONFIG_OPTIMIZATION_LEVEL_DEBUG`.
    /// Controls whether optimization level debug is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    optimization_level_debug: bool = true,
    /// Kconfig key: `CONFIG_OPTIMIZATION_LEVEL_RELEASE`.
    /// Controls whether optimization level release is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    optimization_level_release: bool = false,
    /// Kconfig key: `CONFIG_STACK_CHECK_ALL`.
    /// Controls whether stack check ALL is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    stack_check_all: bool = false,
    /// Kconfig key: `CONFIG_STACK_CHECK_NONE`.
    /// Controls whether stack check NONE is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    stack_check_none: bool = true,
    /// Kconfig key: `CONFIG_STACK_CHECK_NORM`.
    /// Controls whether stack check NORM is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    stack_check_norm: bool = false,
    /// Kconfig key: `CONFIG_STACK_CHECK_STRONG`.
    /// Controls whether stack check strong is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    stack_check_strong: bool = false,
    /// Kconfig key: `CONFIG_WARN_WRITE_STRINGS`.
    /// Controls whether WARN write strings is enabled for the `toolchain` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    warn_write_strings: bool = false,

    pub const default: Config = .{};

    pub fn withDefaultConfig(overrides: anytype) Config {
        return config_overrides.withDefaultConfig(Config, overrides);
    }

    pub fn appendModuleDoc(
        allocator: std.mem.Allocator,
        docs: *std.array_list.Managed(sdkconfig.ModuleDoc),
        cfg: Config,
    ) std.mem.Allocator.Error!void {
        const entries = try allocator.alloc(sdkconfig.Entry, 45);
        entries[0] = sdkconfig.Entry.flag("CONFIG_COMPILER_ASSERT_NDEBUG_EVALUATE", cfg.compiler_assert_ndebug_evaluate);
        entries[1] = sdkconfig.Entry.flag("CONFIG_COMPILER_CXX_EXCEPTIONS", cfg.compiler_cxx_exceptions);
        entries[2] = sdkconfig.Entry.flag("CONFIG_COMPILER_CXX_RTTI", cfg.compiler_cxx_rtti);
        entries[3] = sdkconfig.Entry.flag("CONFIG_COMPILER_DISABLE_DEFAULT_ERRORS", cfg.compiler_disable_default_errors);
        entries[4] = sdkconfig.Entry.flag("CONFIG_COMPILER_DISABLE_GCC12_WARNINGS", cfg.compiler_disable_gcc12_warnings);
        entries[5] = sdkconfig.Entry.flag("CONFIG_COMPILER_DISABLE_GCC13_WARNINGS", cfg.compiler_disable_gcc13_warnings);
        entries[6] = sdkconfig.Entry.flag("CONFIG_COMPILER_DISABLE_GCC14_WARNINGS", cfg.compiler_disable_gcc14_warnings);
        entries[7] = sdkconfig.Entry.flag("CONFIG_COMPILER_DUMP_RTL_FILES", cfg.compiler_dump_rtl_files);
        entries[8] = sdkconfig.Entry.flag("CONFIG_COMPILER_FLOAT_LIB_FROM_GCCLIB", cfg.compiler_float_lib_from_gcclib);
        entries[9] = sdkconfig.Entry.flag("CONFIG_COMPILER_HIDE_PATHS_MACROS", cfg.compiler_hide_paths_macros);
        entries[10] = sdkconfig.Entry.flag("CONFIG_COMPILER_NO_MERGE_CONSTANTS", cfg.compiler_no_merge_constants);
        entries[11] = sdkconfig.Entry.flag("CONFIG_COMPILER_OPTIMIZATION_ASSERTIONS_DISABLE", cfg.compiler_optimization_assertions_disable);
        entries[12] = sdkconfig.Entry.flag("CONFIG_COMPILER_OPTIMIZATION_ASSERTIONS_ENABLE", cfg.compiler_optimization_assertions_enable);
        entries[13] = sdkconfig.Entry.flag("CONFIG_COMPILER_OPTIMIZATION_ASSERTIONS_SILENT", cfg.compiler_optimization_assertions_silent);
        entries[14] = sdkconfig.Entry.int("CONFIG_COMPILER_OPTIMIZATION_ASSERTION_LEVEL", cfg.compiler_optimization_assertion_level);
        entries[15] = sdkconfig.Entry.flag("CONFIG_COMPILER_OPTIMIZATION_CHECKS_SILENT", cfg.compiler_optimization_checks_silent);
        entries[16] = sdkconfig.Entry.flag("CONFIG_COMPILER_OPTIMIZATION_DEBUG", cfg.compiler_optimization_debug);
        entries[17] = sdkconfig.Entry.flag("CONFIG_COMPILER_OPTIMIZATION_DEFAULT", cfg.compiler_optimization_default);
        entries[18] = sdkconfig.Entry.flag("CONFIG_COMPILER_OPTIMIZATION_LEVEL_DEBUG", cfg.compiler_optimization_level_debug);
        entries[19] = sdkconfig.Entry.flag("CONFIG_COMPILER_OPTIMIZATION_LEVEL_RELEASE", cfg.compiler_optimization_level_release);
        entries[20] = sdkconfig.Entry.flag("CONFIG_COMPILER_OPTIMIZATION_NONE", cfg.compiler_optimization_none);
        entries[21] = sdkconfig.Entry.flag("CONFIG_COMPILER_OPTIMIZATION_PERF", cfg.compiler_optimization_perf);
        entries[22] = sdkconfig.Entry.flag("CONFIG_COMPILER_OPTIMIZATION_SIZE", cfg.compiler_optimization_size);
        entries[23] = sdkconfig.Entry.flag("CONFIG_COMPILER_ORPHAN_SECTIONS_PLACE", cfg.compiler_orphan_sections_place);
        entries[24] = sdkconfig.Entry.flag("CONFIG_COMPILER_ORPHAN_SECTIONS_WARNING", cfg.compiler_orphan_sections_warning);
        entries[25] = sdkconfig.Entry.flag("CONFIG_COMPILER_RT_LIB_GCCLIB", cfg.compiler_rt_lib_gcclib);
        entries[26] = sdkconfig.Entry.str("CONFIG_COMPILER_RT_LIB_NAME", cfg.compiler_rt_lib_name);
        entries[27] = sdkconfig.Entry.flag("CONFIG_COMPILER_STACK_CHECK_MODE_ALL", cfg.compiler_stack_check_mode_all);
        entries[28] = sdkconfig.Entry.flag("CONFIG_COMPILER_STACK_CHECK_MODE_NONE", cfg.compiler_stack_check_mode_none);
        entries[29] = sdkconfig.Entry.flag("CONFIG_COMPILER_STACK_CHECK_MODE_NORM", cfg.compiler_stack_check_mode_norm);
        entries[30] = sdkconfig.Entry.flag("CONFIG_COMPILER_STACK_CHECK_MODE_STRONG", cfg.compiler_stack_check_mode_strong);
        entries[31] = sdkconfig.Entry.flag("CONFIG_COMPILER_STATIC_ANALYZER", cfg.compiler_static_analyzer);
        entries[32] = sdkconfig.Entry.flag("CONFIG_COMPILER_WARN_WRITE_STRINGS", cfg.compiler_warn_write_strings);
        entries[33] = sdkconfig.Entry.flag("CONFIG_CXX_EXCEPTIONS", cfg.cxx_exceptions);
        entries[34] = sdkconfig.Entry.flag("CONFIG_OPTIMIZATION_ASSERTIONS_DISABLED", cfg.optimization_assertions_disabled);
        entries[35] = sdkconfig.Entry.flag("CONFIG_OPTIMIZATION_ASSERTIONS_ENABLED", cfg.optimization_assertions_enabled);
        entries[36] = sdkconfig.Entry.flag("CONFIG_OPTIMIZATION_ASSERTIONS_SILENT", cfg.optimization_assertions_silent);
        entries[37] = sdkconfig.Entry.int("CONFIG_OPTIMIZATION_ASSERTION_LEVEL", cfg.optimization_assertion_level);
        entries[38] = sdkconfig.Entry.flag("CONFIG_OPTIMIZATION_LEVEL_DEBUG", cfg.optimization_level_debug);
        entries[39] = sdkconfig.Entry.flag("CONFIG_OPTIMIZATION_LEVEL_RELEASE", cfg.optimization_level_release);
        entries[40] = sdkconfig.Entry.flag("CONFIG_STACK_CHECK_ALL", cfg.stack_check_all);
        entries[41] = sdkconfig.Entry.flag("CONFIG_STACK_CHECK_NONE", cfg.stack_check_none);
        entries[42] = sdkconfig.Entry.flag("CONFIG_STACK_CHECK_NORM", cfg.stack_check_norm);
        entries[43] = sdkconfig.Entry.flag("CONFIG_STACK_CHECK_STRONG", cfg.stack_check_strong);
        entries[44] = sdkconfig.Entry.flag("CONFIG_WARN_WRITE_STRINGS", cfg.warn_write_strings);

        try docs.append(.{
            .name = module_name,
            .entries = entries,
        });
    }
};
