const std = @import("std");
const sdkconfig = @import("../../idf/sdkconfig/idf_mod.zig");
const config_overrides = sdkconfig.config_overrides;

pub const module_name = "target_soc";

pub const Config = struct {
    /// Kconfig key: `CONFIG_ESP32S3_BROWNOUT_DET`.
    /// Controls whether esp32s3 brownout DET is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_brownout_det: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_BROWNOUT_DET_LVL`.
    /// Sets the numeric value for esp32s3 brownout DET LVL in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `7`.
    esp32s3_brownout_det_lvl: i64 = 7,
    /// Kconfig key: `CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_1`.
    /// Controls whether esp32s3 brownout DET LVL SEL 1 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_brownout_det_lvl_sel_1: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_2`.
    /// Controls whether esp32s3 brownout DET LVL SEL 2 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_brownout_det_lvl_sel_2: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_3`.
    /// Controls whether esp32s3 brownout DET LVL SEL 3 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_brownout_det_lvl_sel_3: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_4`.
    /// Controls whether esp32s3 brownout DET LVL SEL 4 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_brownout_det_lvl_sel_4: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_5`.
    /// Controls whether esp32s3 brownout DET LVL SEL 5 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_brownout_det_lvl_sel_5: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_6`.
    /// Controls whether esp32s3 brownout DET LVL SEL 6 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_brownout_det_lvl_sel_6: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_7`.
    /// Controls whether esp32s3 brownout DET LVL SEL 7 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_brownout_det_lvl_sel_7: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_DATA_CACHE_16KB`.
    /// Controls whether esp32s3 DATA cache 16KB is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_data_cache_16kb: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_DATA_CACHE_32KB`.
    /// Controls whether esp32s3 DATA cache 32KB is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_data_cache_32kb: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_DATA_CACHE_4WAYS`.
    /// Controls whether esp32s3 DATA cache 4ways is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_data_cache_4ways: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_DATA_CACHE_64KB`.
    /// Controls whether esp32s3 DATA cache 64KB is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_data_cache_64kb: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_DATA_CACHE_8WAYS`.
    /// Controls whether esp32s3 DATA cache 8ways is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_data_cache_8ways: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_DATA_CACHE_LINE_16B`.
    /// Controls whether esp32s3 DATA cache LINE 16B is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_data_cache_line_16b: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_DATA_CACHE_LINE_32B`.
    /// Controls whether esp32s3 DATA cache LINE 32B is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_data_cache_line_32b: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_DATA_CACHE_LINE_64B`.
    /// Controls whether esp32s3 DATA cache LINE 64B is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_data_cache_line_64b: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_DATA_CACHE_LINE_SIZE`.
    /// Sets the numeric value for esp32s3 DATA cache LINE SIZE in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `32`.
    esp32s3_data_cache_line_size: i64 = 32,
    /// Kconfig key: `CONFIG_ESP32S3_DATA_CACHE_SIZE`.
    /// Sets the literal value for esp32s3 DATA cache SIZE in the `target_soc` module; the value is forwarded into ESP-IDF Kconfig output as configured.
    /// Default: `"0x8000"`.
    esp32s3_data_cache_size: []const u8 = "0x8000",
    /// Kconfig key: `CONFIG_ESP32S3_DCACHE_ASSOCIATED_WAYS`.
    /// Sets the numeric value for esp32s3 dcache associated WAYS in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `8`.
    esp32s3_dcache_associated_ways: i64 = 8,
    /// Kconfig key: `CONFIG_ESP32S3_DEBUG_OCDAWARE`.
    /// Controls whether esp32s3 debug ocdaware is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_debug_ocdaware: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_DEEP_SLEEP_WAKEUP_DELAY`.
    /// Sets the numeric value for esp32s3 DEEP sleep wakeup delay in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `2000`.
    esp32s3_deep_sleep_wakeup_delay: i64 = 2000,
    /// Kconfig key: `CONFIG_ESP32S3_DEFAULT_CPU_FREQ_160`.
    /// Controls whether esp32s3 default CPU FREQ 160 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_default_cpu_freq_160: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_DEFAULT_CPU_FREQ_240`.
    /// Controls whether esp32s3 default CPU FREQ 240 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_default_cpu_freq_240: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_DEFAULT_CPU_FREQ_80`.
    /// Controls whether esp32s3 default CPU FREQ 80 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_default_cpu_freq_80: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_DEFAULT_CPU_FREQ_MHZ`.
    /// Sets the numeric value for esp32s3 default CPU FREQ MHZ in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `160`.
    esp32s3_default_cpu_freq_mhz: i64 = 160,
    /// Kconfig key: `CONFIG_ESP32S3_ICACHE_ASSOCIATED_WAYS`.
    /// Sets the numeric value for esp32s3 icache associated WAYS in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `8`.
    esp32s3_icache_associated_ways: i64 = 8,
    /// Kconfig key: `CONFIG_ESP32S3_INSTRUCTION_CACHE_16KB`.
    /// Controls whether esp32s3 instruction cache 16KB is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_instruction_cache_16kb: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_INSTRUCTION_CACHE_32KB`.
    /// Controls whether esp32s3 instruction cache 32KB is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_instruction_cache_32kb: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_INSTRUCTION_CACHE_4WAYS`.
    /// Controls whether esp32s3 instruction cache 4ways is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_instruction_cache_4ways: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_INSTRUCTION_CACHE_8WAYS`.
    /// Controls whether esp32s3 instruction cache 8ways is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_instruction_cache_8ways: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_INSTRUCTION_CACHE_LINE_16B`.
    /// Controls whether esp32s3 instruction cache LINE 16B is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_instruction_cache_line_16b: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_INSTRUCTION_CACHE_LINE_32B`.
    /// Controls whether esp32s3 instruction cache LINE 32B is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_instruction_cache_line_32b: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_INSTRUCTION_CACHE_LINE_SIZE`.
    /// Sets the numeric value for esp32s3 instruction cache LINE SIZE in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `32`.
    esp32s3_instruction_cache_line_size: i64 = 32,
    /// Kconfig key: `CONFIG_ESP32S3_INSTRUCTION_CACHE_SIZE`.
    /// Sets the literal value for esp32s3 instruction cache SIZE in the `target_soc` module; the value is forwarded into ESP-IDF Kconfig output as configured.
    /// Default: `"0x4000"`.
    esp32s3_instruction_cache_size: []const u8 = "0x4000",
    /// Kconfig key: `CONFIG_ESP32S3_REV_MAX_FULL`.
    /// Sets the numeric value for esp32s3 REV MAX FULL in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `99`.
    esp32s3_rev_max_full: i64 = 99,
    /// Kconfig key: `CONFIG_ESP32S3_REV_MIN_0`.
    /// Controls whether esp32s3 REV MIN 0 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_rev_min_0: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_REV_MIN_1`.
    /// Controls whether esp32s3 REV MIN 1 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_rev_min_1: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_REV_MIN_2`.
    /// Controls whether esp32s3 REV MIN 2 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_rev_min_2: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_REV_MIN_FULL`.
    /// Sets the numeric value for esp32s3 REV MIN FULL in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `0`.
    esp32s3_rev_min_full: i64 = 0,
    /// Kconfig key: `CONFIG_ESP32S3_RTCDATA_IN_FAST_MEM`.
    /// Controls whether esp32s3 rtcdata IN FAST MEM is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_rtcdata_in_fast_mem: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_RTC_CLK_CAL_CYCLES`.
    /// Sets the numeric value for esp32s3 RTC CLK CAL cycles in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `1024`.
    esp32s3_rtc_clk_cal_cycles: i64 = 1024,
    /// Kconfig key: `CONFIG_ESP32S3_RTC_CLK_SRC_EXT_CRYS`.
    /// Controls whether esp32s3 RTC CLK SRC EXT CRYS is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_rtc_clk_src_ext_crys: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_RTC_CLK_SRC_EXT_OSC`.
    /// Controls whether esp32s3 RTC CLK SRC EXT OSC is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_rtc_clk_src_ext_osc: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_RTC_CLK_SRC_INT_8MD256`.
    /// Controls whether esp32s3 RTC CLK SRC INT 8md256 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_rtc_clk_src_int_8md256: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_RTC_CLK_SRC_INT_RC`.
    /// Controls whether esp32s3 RTC CLK SRC INT RC is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_rtc_clk_src_int_rc: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_SPIRAM_SUPPORT`.
    /// Controls whether esp32s3 spiram support is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_spiram_support: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_TIME_SYSCALL_USE_FRC1`.
    /// Controls whether esp32s3 TIME syscall USE FRC1 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_time_syscall_use_frc1: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_TIME_SYSCALL_USE_NONE`.
    /// Controls whether esp32s3 TIME syscall USE NONE is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_time_syscall_use_none: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_TIME_SYSCALL_USE_RTC`.
    /// Controls whether esp32s3 TIME syscall USE RTC is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_time_syscall_use_rtc: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_TIME_SYSCALL_USE_RTC_FRC1`.
    /// Controls whether esp32s3 TIME syscall USE RTC FRC1 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_time_syscall_use_rtc_frc1: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_TIME_SYSCALL_USE_RTC_SYSTIMER`.
    /// Controls whether esp32s3 TIME syscall USE RTC systimer is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_time_syscall_use_rtc_systimer: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_TIME_SYSCALL_USE_SYSTIMER`.
    /// Controls whether esp32s3 TIME syscall USE systimer is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_time_syscall_use_systimer: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_TRACEMEM_RESERVE_DRAM`.
    /// Sets the literal value for esp32s3 tracemem reserve DRAM in the `target_soc` module; the value is forwarded into ESP-IDF Kconfig output as configured.
    /// Default: `"0x0"`.
    esp32s3_tracemem_reserve_dram: []const u8 = "0x0",
    /// Kconfig key: `CONFIG_ESP32S3_TRAX`.
    /// Controls whether esp32s3 TRAX is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_trax: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_UNIVERSAL_MAC_ADDRESSES`.
    /// Sets the numeric value for esp32s3 universal MAC addresses in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `4`.
    esp32s3_universal_mac_addresses: i64 = 4,
    /// Kconfig key: `CONFIG_ESP32S3_UNIVERSAL_MAC_ADDRESSES_FOUR`.
    /// Controls whether esp32s3 universal MAC addresses FOUR is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32s3_universal_mac_addresses_four: bool = true,
    /// Kconfig key: `CONFIG_ESP32S3_UNIVERSAL_MAC_ADDRESSES_TWO`.
    /// Controls whether esp32s3 universal MAC addresses TWO is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_universal_mac_addresses_two: bool = false,
    /// Kconfig key: `CONFIG_ESP32S3_USE_FIXED_STATIC_RAM_SIZE`.
    /// Controls whether esp32s3 USE fixed static RAM SIZE is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32s3_use_fixed_static_ram_size: bool = false,
    /// Kconfig key: `CONFIG_ESP32_APPTRACE_DEST_NONE`.
    /// Controls whether esp32 apptrace DEST NONE is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32_apptrace_dest_none: bool = true,
    /// Kconfig key: `CONFIG_ESP32_APPTRACE_DEST_TRAX`.
    /// Controls whether esp32 apptrace DEST TRAX is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32_apptrace_dest_trax: bool = false,
    /// Kconfig key: `CONFIG_ESP32_APPTRACE_LOCK_ENABLE`.
    /// Controls whether esp32 apptrace LOCK enable is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32_apptrace_lock_enable: bool = true,
    /// Kconfig key: `CONFIG_ESP32_DEBUG_STUBS_ENABLE`.
    /// Controls whether esp32 debug stubs enable is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32_debug_stubs_enable: bool = false,
    /// Kconfig key: `CONFIG_ESP32_DEFAULT_PTHREAD_CORE_0`.
    /// Controls whether esp32 default pthread CORE 0 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32_default_pthread_core_0: bool = false,
    /// Kconfig key: `CONFIG_ESP32_DEFAULT_PTHREAD_CORE_1`.
    /// Controls whether esp32 default pthread CORE 1 is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32_default_pthread_core_1: bool = false,
    /// Kconfig key: `CONFIG_ESP32_DEFAULT_PTHREAD_CORE_NO_AFFINITY`.
    /// Controls whether esp32 default pthread CORE NO affinity is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32_default_pthread_core_no_affinity: bool = true,
    /// Kconfig key: `CONFIG_ESP32_ENABLE_COREDUMP_TO_FLASH`.
    /// Controls whether esp32 enable coredump TO flash is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32_enable_coredump_to_flash: bool = false,
    /// Kconfig key: `CONFIG_ESP32_ENABLE_COREDUMP_TO_NONE`.
    /// Controls whether esp32 enable coredump TO NONE is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp32_enable_coredump_to_none: bool = true,
    /// Kconfig key: `CONFIG_ESP32_ENABLE_COREDUMP_TO_UART`.
    /// Controls whether esp32 enable coredump TO UART is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32_enable_coredump_to_uart: bool = false,
    /// Kconfig key: `CONFIG_ESP32_PTHREAD_STACK_MIN`.
    /// Sets the numeric value for esp32 pthread stack MIN in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `768`.
    esp32_pthread_stack_min: i64 = 768,
    /// Kconfig key: `CONFIG_ESP32_PTHREAD_TASK_CORE_DEFAULT`.
    /// Sets the numeric value for esp32 pthread TASK CORE default in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `-1`.
    esp32_pthread_task_core_default: i64 = -1,
    /// Kconfig key: `CONFIG_ESP32_PTHREAD_TASK_NAME_DEFAULT`.
    /// Sets the literal value for esp32 pthread TASK NAME default in the `target_soc` module; the value is forwarded into ESP-IDF Kconfig output as configured.
    /// Default: `"pthread"`.
    esp32_pthread_task_name_default: []const u8 = "pthread",
    /// Kconfig key: `CONFIG_ESP32_PTHREAD_TASK_PRIO_DEFAULT`.
    /// Sets the numeric value for esp32 pthread TASK PRIO default in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `5`.
    esp32_pthread_task_prio_default: i64 = 5,
    /// Kconfig key: `CONFIG_ESP32_PTHREAD_TASK_STACK_SIZE_DEFAULT`.
    /// Sets the numeric value for esp32 pthread TASK stack SIZE default in the `target_soc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `3072`.
    esp32_pthread_task_stack_size_default: i64 = 3072,
    /// Kconfig key: `CONFIG_ESP32_REDUCE_PHY_TX_POWER`.
    /// Controls whether esp32 reduce PHY TX power is enabled for the `target_soc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp32_reduce_phy_tx_power: bool = false,

    pub const default: Config = .{};

    pub fn withDefaultConfig(overrides: anytype) Config {
        return config_overrides.withDefaultConfig(Config, overrides);
    }

    pub fn appendModuleDoc(
        allocator: std.mem.Allocator,
        docs: *std.array_list.Managed(sdkconfig.ModuleDoc),
        cfg: Config,
    ) std.mem.Allocator.Error!void {
        const entries = try allocator.alloc(sdkconfig.Entry, 75);
        entries[0] = sdkconfig.Entry.flag("CONFIG_ESP32S3_BROWNOUT_DET", cfg.esp32s3_brownout_det);
        entries[1] = sdkconfig.Entry.int("CONFIG_ESP32S3_BROWNOUT_DET_LVL", cfg.esp32s3_brownout_det_lvl);
        entries[2] = sdkconfig.Entry.flag("CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_1", cfg.esp32s3_brownout_det_lvl_sel_1);
        entries[3] = sdkconfig.Entry.flag("CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_2", cfg.esp32s3_brownout_det_lvl_sel_2);
        entries[4] = sdkconfig.Entry.flag("CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_3", cfg.esp32s3_brownout_det_lvl_sel_3);
        entries[5] = sdkconfig.Entry.flag("CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_4", cfg.esp32s3_brownout_det_lvl_sel_4);
        entries[6] = sdkconfig.Entry.flag("CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_5", cfg.esp32s3_brownout_det_lvl_sel_5);
        entries[7] = sdkconfig.Entry.flag("CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_6", cfg.esp32s3_brownout_det_lvl_sel_6);
        entries[8] = sdkconfig.Entry.flag("CONFIG_ESP32S3_BROWNOUT_DET_LVL_SEL_7", cfg.esp32s3_brownout_det_lvl_sel_7);
        entries[9] = sdkconfig.Entry.flag("CONFIG_ESP32S3_DATA_CACHE_16KB", cfg.esp32s3_data_cache_16kb);
        entries[10] = sdkconfig.Entry.flag("CONFIG_ESP32S3_DATA_CACHE_32KB", cfg.esp32s3_data_cache_32kb);
        entries[11] = sdkconfig.Entry.flag("CONFIG_ESP32S3_DATA_CACHE_4WAYS", cfg.esp32s3_data_cache_4ways);
        entries[12] = sdkconfig.Entry.flag("CONFIG_ESP32S3_DATA_CACHE_64KB", cfg.esp32s3_data_cache_64kb);
        entries[13] = sdkconfig.Entry.flag("CONFIG_ESP32S3_DATA_CACHE_8WAYS", cfg.esp32s3_data_cache_8ways);
        entries[14] = sdkconfig.Entry.flag("CONFIG_ESP32S3_DATA_CACHE_LINE_16B", cfg.esp32s3_data_cache_line_16b);
        entries[15] = sdkconfig.Entry.flag("CONFIG_ESP32S3_DATA_CACHE_LINE_32B", cfg.esp32s3_data_cache_line_32b);
        entries[16] = sdkconfig.Entry.flag("CONFIG_ESP32S3_DATA_CACHE_LINE_64B", cfg.esp32s3_data_cache_line_64b);
        entries[17] = sdkconfig.Entry.int("CONFIG_ESP32S3_DATA_CACHE_LINE_SIZE", cfg.esp32s3_data_cache_line_size);
        entries[18] = sdkconfig.Entry.raw("CONFIG_ESP32S3_DATA_CACHE_SIZE", cfg.esp32s3_data_cache_size);
        entries[19] = sdkconfig.Entry.int("CONFIG_ESP32S3_DCACHE_ASSOCIATED_WAYS", cfg.esp32s3_dcache_associated_ways);
        entries[20] = sdkconfig.Entry.flag("CONFIG_ESP32S3_DEBUG_OCDAWARE", cfg.esp32s3_debug_ocdaware);
        entries[21] = sdkconfig.Entry.int("CONFIG_ESP32S3_DEEP_SLEEP_WAKEUP_DELAY", cfg.esp32s3_deep_sleep_wakeup_delay);
        entries[22] = sdkconfig.Entry.flag("CONFIG_ESP32S3_DEFAULT_CPU_FREQ_160", cfg.esp32s3_default_cpu_freq_160);
        entries[23] = sdkconfig.Entry.flag("CONFIG_ESP32S3_DEFAULT_CPU_FREQ_240", cfg.esp32s3_default_cpu_freq_240);
        entries[24] = sdkconfig.Entry.flag("CONFIG_ESP32S3_DEFAULT_CPU_FREQ_80", cfg.esp32s3_default_cpu_freq_80);
        entries[25] = sdkconfig.Entry.int("CONFIG_ESP32S3_DEFAULT_CPU_FREQ_MHZ", cfg.esp32s3_default_cpu_freq_mhz);
        entries[26] = sdkconfig.Entry.int("CONFIG_ESP32S3_ICACHE_ASSOCIATED_WAYS", cfg.esp32s3_icache_associated_ways);
        entries[27] = sdkconfig.Entry.flag("CONFIG_ESP32S3_INSTRUCTION_CACHE_16KB", cfg.esp32s3_instruction_cache_16kb);
        entries[28] = sdkconfig.Entry.flag("CONFIG_ESP32S3_INSTRUCTION_CACHE_32KB", cfg.esp32s3_instruction_cache_32kb);
        entries[29] = sdkconfig.Entry.flag("CONFIG_ESP32S3_INSTRUCTION_CACHE_4WAYS", cfg.esp32s3_instruction_cache_4ways);
        entries[30] = sdkconfig.Entry.flag("CONFIG_ESP32S3_INSTRUCTION_CACHE_8WAYS", cfg.esp32s3_instruction_cache_8ways);
        entries[31] = sdkconfig.Entry.flag("CONFIG_ESP32S3_INSTRUCTION_CACHE_LINE_16B", cfg.esp32s3_instruction_cache_line_16b);
        entries[32] = sdkconfig.Entry.flag("CONFIG_ESP32S3_INSTRUCTION_CACHE_LINE_32B", cfg.esp32s3_instruction_cache_line_32b);
        entries[33] = sdkconfig.Entry.int("CONFIG_ESP32S3_INSTRUCTION_CACHE_LINE_SIZE", cfg.esp32s3_instruction_cache_line_size);
        entries[34] = sdkconfig.Entry.raw("CONFIG_ESP32S3_INSTRUCTION_CACHE_SIZE", cfg.esp32s3_instruction_cache_size);
        entries[35] = sdkconfig.Entry.int("CONFIG_ESP32S3_REV_MAX_FULL", cfg.esp32s3_rev_max_full);
        entries[36] = sdkconfig.Entry.flag("CONFIG_ESP32S3_REV_MIN_0", cfg.esp32s3_rev_min_0);
        entries[37] = sdkconfig.Entry.flag("CONFIG_ESP32S3_REV_MIN_1", cfg.esp32s3_rev_min_1);
        entries[38] = sdkconfig.Entry.flag("CONFIG_ESP32S3_REV_MIN_2", cfg.esp32s3_rev_min_2);
        entries[39] = sdkconfig.Entry.int("CONFIG_ESP32S3_REV_MIN_FULL", cfg.esp32s3_rev_min_full);
        entries[40] = sdkconfig.Entry.flag("CONFIG_ESP32S3_RTCDATA_IN_FAST_MEM", cfg.esp32s3_rtcdata_in_fast_mem);
        entries[41] = sdkconfig.Entry.int("CONFIG_ESP32S3_RTC_CLK_CAL_CYCLES", cfg.esp32s3_rtc_clk_cal_cycles);
        entries[42] = sdkconfig.Entry.flag("CONFIG_ESP32S3_RTC_CLK_SRC_EXT_CRYS", cfg.esp32s3_rtc_clk_src_ext_crys);
        entries[43] = sdkconfig.Entry.flag("CONFIG_ESP32S3_RTC_CLK_SRC_EXT_OSC", cfg.esp32s3_rtc_clk_src_ext_osc);
        entries[44] = sdkconfig.Entry.flag("CONFIG_ESP32S3_RTC_CLK_SRC_INT_8MD256", cfg.esp32s3_rtc_clk_src_int_8md256);
        entries[45] = sdkconfig.Entry.flag("CONFIG_ESP32S3_RTC_CLK_SRC_INT_RC", cfg.esp32s3_rtc_clk_src_int_rc);
        entries[46] = sdkconfig.Entry.flag("CONFIG_ESP32S3_SPIRAM_SUPPORT", cfg.esp32s3_spiram_support);
        entries[47] = sdkconfig.Entry.flag("CONFIG_ESP32S3_TIME_SYSCALL_USE_FRC1", cfg.esp32s3_time_syscall_use_frc1);
        entries[48] = sdkconfig.Entry.flag("CONFIG_ESP32S3_TIME_SYSCALL_USE_NONE", cfg.esp32s3_time_syscall_use_none);
        entries[49] = sdkconfig.Entry.flag("CONFIG_ESP32S3_TIME_SYSCALL_USE_RTC", cfg.esp32s3_time_syscall_use_rtc);
        entries[50] = sdkconfig.Entry.flag("CONFIG_ESP32S3_TIME_SYSCALL_USE_RTC_FRC1", cfg.esp32s3_time_syscall_use_rtc_frc1);
        entries[51] = sdkconfig.Entry.flag("CONFIG_ESP32S3_TIME_SYSCALL_USE_RTC_SYSTIMER", cfg.esp32s3_time_syscall_use_rtc_systimer);
        entries[52] = sdkconfig.Entry.flag("CONFIG_ESP32S3_TIME_SYSCALL_USE_SYSTIMER", cfg.esp32s3_time_syscall_use_systimer);
        entries[53] = sdkconfig.Entry.raw("CONFIG_ESP32S3_TRACEMEM_RESERVE_DRAM", cfg.esp32s3_tracemem_reserve_dram);
        entries[54] = sdkconfig.Entry.flag("CONFIG_ESP32S3_TRAX", cfg.esp32s3_trax);
        entries[55] = sdkconfig.Entry.int("CONFIG_ESP32S3_UNIVERSAL_MAC_ADDRESSES", cfg.esp32s3_universal_mac_addresses);
        entries[56] = sdkconfig.Entry.flag("CONFIG_ESP32S3_UNIVERSAL_MAC_ADDRESSES_FOUR", cfg.esp32s3_universal_mac_addresses_four);
        entries[57] = sdkconfig.Entry.flag("CONFIG_ESP32S3_UNIVERSAL_MAC_ADDRESSES_TWO", cfg.esp32s3_universal_mac_addresses_two);
        entries[58] = sdkconfig.Entry.flag("CONFIG_ESP32S3_USE_FIXED_STATIC_RAM_SIZE", cfg.esp32s3_use_fixed_static_ram_size);
        entries[59] = sdkconfig.Entry.flag("CONFIG_ESP32_APPTRACE_DEST_NONE", cfg.esp32_apptrace_dest_none);
        entries[60] = sdkconfig.Entry.flag("CONFIG_ESP32_APPTRACE_DEST_TRAX", cfg.esp32_apptrace_dest_trax);
        entries[61] = sdkconfig.Entry.flag("CONFIG_ESP32_APPTRACE_LOCK_ENABLE", cfg.esp32_apptrace_lock_enable);
        entries[62] = sdkconfig.Entry.flag("CONFIG_ESP32_DEBUG_STUBS_ENABLE", cfg.esp32_debug_stubs_enable);
        entries[63] = sdkconfig.Entry.flag("CONFIG_ESP32_DEFAULT_PTHREAD_CORE_0", cfg.esp32_default_pthread_core_0);
        entries[64] = sdkconfig.Entry.flag("CONFIG_ESP32_DEFAULT_PTHREAD_CORE_1", cfg.esp32_default_pthread_core_1);
        entries[65] = sdkconfig.Entry.flag("CONFIG_ESP32_DEFAULT_PTHREAD_CORE_NO_AFFINITY", cfg.esp32_default_pthread_core_no_affinity);
        entries[66] = sdkconfig.Entry.flag("CONFIG_ESP32_ENABLE_COREDUMP_TO_FLASH", cfg.esp32_enable_coredump_to_flash);
        entries[67] = sdkconfig.Entry.flag("CONFIG_ESP32_ENABLE_COREDUMP_TO_NONE", cfg.esp32_enable_coredump_to_none);
        entries[68] = sdkconfig.Entry.flag("CONFIG_ESP32_ENABLE_COREDUMP_TO_UART", cfg.esp32_enable_coredump_to_uart);
        entries[69] = sdkconfig.Entry.int("CONFIG_ESP32_PTHREAD_STACK_MIN", cfg.esp32_pthread_stack_min);
        entries[70] = sdkconfig.Entry.int("CONFIG_ESP32_PTHREAD_TASK_CORE_DEFAULT", cfg.esp32_pthread_task_core_default);
        entries[71] = sdkconfig.Entry.str("CONFIG_ESP32_PTHREAD_TASK_NAME_DEFAULT", cfg.esp32_pthread_task_name_default);
        entries[72] = sdkconfig.Entry.int("CONFIG_ESP32_PTHREAD_TASK_PRIO_DEFAULT", cfg.esp32_pthread_task_prio_default);
        entries[73] = sdkconfig.Entry.int("CONFIG_ESP32_PTHREAD_TASK_STACK_SIZE_DEFAULT", cfg.esp32_pthread_task_stack_size_default);
        entries[74] = sdkconfig.Entry.flag("CONFIG_ESP32_REDUCE_PHY_TX_POWER", cfg.esp32_reduce_phy_tx_power);

        try docs.append(.{
            .name = module_name,
            .entries = entries,
        });
    }
};
