const std = @import("std");
const sdkconfig = @import("../../idf/sdkconfig/idf_mod.zig");
const config_overrides = sdkconfig.config_overrides;

pub const module_name = "esp_misc";

pub const Config = struct {
    /// Kconfig key: `CONFIG_ESP_BROWNOUT_DET`.
    /// Controls whether ESP brownout DET is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_brownout_det: bool = true,
    /// Kconfig key: `CONFIG_ESP_BROWNOUT_DET_LVL`.
    /// Sets the numeric value for ESP brownout DET LVL in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `7`.
    esp_brownout_det_lvl: i64 = 7,
    /// Kconfig key: `CONFIG_ESP_BROWNOUT_DET_LVL_SEL_1`.
    /// Controls whether ESP brownout DET LVL SEL 1 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_brownout_det_lvl_sel_1: bool = false,
    /// Kconfig key: `CONFIG_ESP_BROWNOUT_DET_LVL_SEL_2`.
    /// Controls whether ESP brownout DET LVL SEL 2 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_brownout_det_lvl_sel_2: bool = false,
    /// Kconfig key: `CONFIG_ESP_BROWNOUT_DET_LVL_SEL_3`.
    /// Controls whether ESP brownout DET LVL SEL 3 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_brownout_det_lvl_sel_3: bool = false,
    /// Kconfig key: `CONFIG_ESP_BROWNOUT_DET_LVL_SEL_4`.
    /// Controls whether ESP brownout DET LVL SEL 4 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_brownout_det_lvl_sel_4: bool = false,
    /// Kconfig key: `CONFIG_ESP_BROWNOUT_DET_LVL_SEL_5`.
    /// Controls whether ESP brownout DET LVL SEL 5 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_brownout_det_lvl_sel_5: bool = false,
    /// Kconfig key: `CONFIG_ESP_BROWNOUT_DET_LVL_SEL_6`.
    /// Controls whether ESP brownout DET LVL SEL 6 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_brownout_det_lvl_sel_6: bool = false,
    /// Kconfig key: `CONFIG_ESP_BROWNOUT_DET_LVL_SEL_7`.
    /// Controls whether ESP brownout DET LVL SEL 7 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_brownout_det_lvl_sel_7: bool = true,
    /// Kconfig key: `CONFIG_ESP_CONSOLE_NONE`.
    /// Controls whether ESP console NONE is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_console_none: bool = false,
    /// Kconfig key: `CONFIG_ESP_CONSOLE_ROM_SERIAL_PORT_NUM`.
    /// Sets the numeric value for ESP console ROM serial PORT NUM in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `0`.
    esp_console_rom_serial_port_num: i64 = 0,
    /// Kconfig key: `CONFIG_ESP_CONSOLE_SECONDARY_NONE`.
    /// Controls whether ESP console secondary NONE is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_console_secondary_none: bool = false,
    /// Kconfig key: `CONFIG_ESP_CONSOLE_SECONDARY_USB_SERIAL_JTAG`.
    /// Controls whether ESP console secondary USB serial JTAG is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_console_secondary_usb_serial_jtag: bool = true,
    /// Kconfig key: `CONFIG_ESP_CONSOLE_UART`.
    /// Controls whether ESP console UART is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_console_uart: bool = true,
    /// Kconfig key: `CONFIG_ESP_CONSOLE_UART_BAUDRATE`.
    /// Sets the numeric value for ESP console UART baudrate in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `115200`.
    esp_console_uart_baudrate: i64 = 115200,
    /// Kconfig key: `CONFIG_ESP_CONSOLE_UART_CUSTOM`.
    /// Controls whether ESP console UART custom is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_console_uart_custom: bool = false,
    /// Kconfig key: `CONFIG_ESP_CONSOLE_UART_DEFAULT`.
    /// Controls whether ESP console UART default is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_console_uart_default: bool = true,
    /// Kconfig key: `CONFIG_ESP_CONSOLE_UART_NONE`.
    /// Controls whether ESP console UART NONE is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_console_uart_none: bool = false,
    /// Kconfig key: `CONFIG_ESP_CONSOLE_UART_NUM`.
    /// Sets the numeric value for ESP console UART NUM in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `0`.
    esp_console_uart_num: i64 = 0,
    /// Kconfig key: `CONFIG_ESP_CONSOLE_USB_CDC`.
    /// Controls whether ESP console USB CDC is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_console_usb_cdc: bool = false,
    /// Kconfig key: `CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG`.
    /// Controls whether ESP console USB serial JTAG is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_console_usb_serial_jtag: bool = false,
    /// Kconfig key: `CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG_ENABLED`.
    /// Controls whether ESP console USB serial JTAG enabled is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_console_usb_serial_jtag_enabled: bool = true,
    /// Kconfig key: `CONFIG_ESP_DEBUG_OCDAWARE`.
    /// Controls whether ESP debug ocdaware is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_debug_ocdaware: bool = true,
    /// Kconfig key: `CONFIG_ESP_DEBUG_STUBS_ENABLE`.
    /// Controls whether ESP debug stubs enable is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_debug_stubs_enable: bool = false,
    /// Kconfig key: `CONFIG_ESP_DEFAULT_CPU_FREQ_MHZ`.
    /// Sets the numeric value for ESP default CPU FREQ MHZ in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `160`.
    esp_default_cpu_freq_mhz: i64 = 160,
    /// Kconfig key: `CONFIG_ESP_DEFAULT_CPU_FREQ_MHZ_160`.
    /// Controls whether ESP default CPU FREQ MHZ 160 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_default_cpu_freq_mhz_160: bool = true,
    /// Kconfig key: `CONFIG_ESP_DEFAULT_CPU_FREQ_MHZ_240`.
    /// Controls whether ESP default CPU FREQ MHZ 240 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_default_cpu_freq_mhz_240: bool = false,
    /// Kconfig key: `CONFIG_ESP_DEFAULT_CPU_FREQ_MHZ_80`.
    /// Controls whether ESP default CPU FREQ MHZ 80 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_default_cpu_freq_mhz_80: bool = false,
    /// Kconfig key: `CONFIG_ESP_EFUSE_BLOCK_REV_MAX_FULL`.
    /// Sets the numeric value for ESP efuse block REV MAX FULL in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `199`.
    esp_efuse_block_rev_max_full: i64 = 199,
    /// Kconfig key: `CONFIG_ESP_EFUSE_BLOCK_REV_MIN_FULL`.
    /// Sets the numeric value for ESP efuse block REV MIN FULL in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `0`.
    esp_efuse_block_rev_min_full: i64 = 0,
    /// Kconfig key: `CONFIG_ESP_ERR_TO_NAME_LOOKUP`.
    /// Controls whether ESP ERR TO NAME lookup is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_err_to_name_lookup: bool = true,
    /// Kconfig key: `CONFIG_ESP_GRATUITOUS_ARP`.
    /// Controls whether ESP gratuitous ARP is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_gratuitous_arp: bool = true,
    /// Kconfig key: `CONFIG_ESP_INT_WDT`.
    /// Controls whether ESP INT WDT is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_int_wdt: bool = true,
    /// Kconfig key: `CONFIG_ESP_INT_WDT_CHECK_CPU1`.
    /// Controls whether ESP INT WDT check CPU1 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_int_wdt_check_cpu1: bool = true,
    /// Kconfig key: `CONFIG_ESP_INT_WDT_TIMEOUT_MS`.
    /// Sets the numeric value for ESP INT WDT timeout MS in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `300`.
    esp_int_wdt_timeout_ms: i64 = 300,
    /// Kconfig key: `CONFIG_ESP_IPC_ISR_ENABLE`.
    /// Controls whether ESP IPC ISR enable is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_ipc_isr_enable: bool = true,
    /// Kconfig key: `CONFIG_ESP_IPC_TASK_STACK_SIZE`.
    /// Sets the numeric value for ESP IPC TASK stack SIZE in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `1280`.
    esp_ipc_task_stack_size: i64 = 1280,
    /// Kconfig key: `CONFIG_ESP_IPC_USES_CALLERS_PRIORITY`.
    /// Controls whether ESP IPC USES callers priority is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_ipc_uses_callers_priority: bool = true,
    /// Kconfig key: `CONFIG_ESP_MAC_ADDR_UNIVERSE_BT`.
    /// Controls whether ESP MAC ADDR universe BT is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_mac_addr_universe_bt: bool = true,
    /// Kconfig key: `CONFIG_ESP_MAC_ADDR_UNIVERSE_ETH`.
    /// Controls whether ESP MAC ADDR universe ETH is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_mac_addr_universe_eth: bool = true,
    /// Kconfig key: `CONFIG_ESP_MAC_ADDR_UNIVERSE_WIFI_AP`.
    /// Controls whether ESP MAC ADDR universe WIFI AP is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_mac_addr_universe_wifi_ap: bool = true,
    /// Kconfig key: `CONFIG_ESP_MAC_ADDR_UNIVERSE_WIFI_STA`.
    /// Controls whether ESP MAC ADDR universe WIFI STA is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_mac_addr_universe_wifi_sta: bool = true,
    /// Kconfig key: `CONFIG_ESP_MAC_UNIVERSAL_MAC_ADDRESSES`.
    /// Sets the numeric value for ESP MAC universal MAC addresses in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `4`.
    esp_mac_universal_mac_addresses: i64 = 4,
    /// Kconfig key: `CONFIG_ESP_MAC_UNIVERSAL_MAC_ADDRESSES_FOUR`.
    /// Controls whether ESP MAC universal MAC addresses FOUR is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_mac_universal_mac_addresses_four: bool = true,
    /// Kconfig key: `CONFIG_ESP_MAC_USE_CUSTOM_MAC_AS_BASE_MAC`.
    /// Controls whether ESP MAC USE custom MAC AS BASE MAC is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_mac_use_custom_mac_as_base_mac: bool = false,
    /// Kconfig key: `CONFIG_ESP_MAIN_TASK_AFFINITY`.
    /// Sets the literal value for ESP MAIN TASK affinity in the `esp_misc` module; the value is forwarded into ESP-IDF Kconfig output as configured.
    /// Default: `"0x0"`.
    esp_main_task_affinity: []const u8 = "0x0",
    /// Kconfig key: `CONFIG_ESP_MAIN_TASK_AFFINITY_CPU0`.
    /// Controls whether ESP MAIN TASK affinity CPU0 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_main_task_affinity_cpu0: bool = true,
    /// Kconfig key: `CONFIG_ESP_MAIN_TASK_AFFINITY_CPU1`.
    /// Controls whether ESP MAIN TASK affinity CPU1 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_main_task_affinity_cpu1: bool = false,
    /// Kconfig key: `CONFIG_ESP_MAIN_TASK_AFFINITY_NO_AFFINITY`.
    /// Controls whether ESP MAIN TASK affinity NO affinity is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_main_task_affinity_no_affinity: bool = false,
    /// Kconfig key: `CONFIG_ESP_MAIN_TASK_STACK_SIZE`.
    /// Sets the numeric value for ESP MAIN TASK stack SIZE in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `3584`.
    esp_main_task_stack_size: i64 = 3584,
    /// Kconfig key: `CONFIG_ESP_MINIMAL_SHARED_STACK_SIZE`.
    /// Sets the numeric value for ESP minimal shared stack SIZE in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `2048`.
    esp_minimal_shared_stack_size: i64 = 2048,
    /// Kconfig key: `CONFIG_ESP_MM_CACHE_MSYNC_C2M_CHUNKED_OPS`.
    /// Controls whether ESP MM cache msync C2M chunked OPS is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_mm_cache_msync_c2m_chunked_ops: bool = false,
    /// Kconfig key: `CONFIG_ESP_PANIC_HANDLER_IRAM`.
    /// Controls whether ESP panic handler IRAM is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_panic_handler_iram: bool = false,
    /// Kconfig key: `CONFIG_ESP_PROTOCOMM_SUPPORT_SECURITY_VERSION_0`.
    /// Controls whether ESP protocomm support security version 0 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_protocomm_support_security_version_0: bool = true,
    /// Kconfig key: `CONFIG_ESP_PROTOCOMM_SUPPORT_SECURITY_VERSION_1`.
    /// Controls whether ESP protocomm support security version 1 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_protocomm_support_security_version_1: bool = true,
    /// Kconfig key: `CONFIG_ESP_PROTOCOMM_SUPPORT_SECURITY_VERSION_2`.
    /// Controls whether ESP protocomm support security version 2 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_protocomm_support_security_version_2: bool = true,
    /// Kconfig key: `CONFIG_ESP_REV_MAX_FULL`.
    /// Sets the numeric value for ESP REV MAX FULL in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `99`.
    esp_rev_max_full: i64 = 99,
    /// Kconfig key: `CONFIG_ESP_REV_MIN_FULL`.
    /// Sets the numeric value for ESP REV MIN FULL in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `0`.
    esp_rev_min_full: i64 = 0,
    /// Kconfig key: `CONFIG_ESP_ROM_GET_CLK_FREQ`.
    /// Controls whether ESP ROM GET CLK FREQ is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_get_clk_freq: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_CACHE_SUSPEND_WAITI_BUG`.
    /// Controls whether ESP ROM HAS cache suspend waiti BUG is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_cache_suspend_waiti_bug: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_CACHE_WRITEBACK_BUG`.
    /// Controls whether ESP ROM HAS cache writeback BUG is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_cache_writeback_bug: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_CRC_BE`.
    /// Controls whether ESP ROM HAS CRC BE is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_crc_be: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_CRC_LE`.
    /// Controls whether ESP ROM HAS CRC LE is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_crc_le: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_ENCRYPTED_WRITES_USING_LEGACY_DRV`.
    /// Controls whether ESP ROM HAS encrypted writes using legacy DRV is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_encrypted_writes_using_legacy_drv: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_ERASE_0_REGION_BUG`.
    /// Controls whether ESP ROM HAS erase 0 region BUG is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_erase_0_region_bug: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_ETS_PRINTF_BUG`.
    /// Controls whether ESP ROM HAS ETS printf BUG is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_ets_printf_bug: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_FLASH_COUNT_PAGES_BUG`.
    /// Controls whether ESP ROM HAS flash count pages BUG is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_flash_count_pages_bug: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_HAL_WDT`.
    /// Controls whether ESP ROM HAS HAL WDT is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_hal_wdt: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_JPEG_DECODE`.
    /// Controls whether ESP ROM HAS JPEG decode is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_jpeg_decode: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_LAYOUT_TABLE`.
    /// Controls whether ESP ROM HAS layout table is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_layout_table: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_MZ_CRC32`.
    /// Controls whether ESP ROM HAS MZ crc32 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_mz_crc32: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_NEWLIB`.
    /// Controls whether ESP ROM HAS newlib is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_newlib: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_NEWLIB_32BIT_TIME`.
    /// Controls whether ESP ROM HAS newlib 32bit TIME is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_newlib_32bit_time: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_NEWLIB_NANO_FORMAT`.
    /// Controls whether ESP ROM HAS newlib NANO format is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_newlib_nano_format: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_OUTPUT_PUTC_FUNC`.
    /// Controls whether ESP ROM HAS output PUTC FUNC is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_output_putc_func: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_RETARGETABLE_LOCKING`.
    /// Controls whether ESP ROM HAS retargetable locking is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_retargetable_locking: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_SPI_FLASH`.
    /// Controls whether ESP ROM HAS SPI flash is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_spi_flash: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_SW_FLOAT`.
    /// Controls whether ESP ROM HAS SW float is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_sw_float: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_HAS_VERSION`.
    /// Controls whether ESP ROM HAS version is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_has_version: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_NEEDS_SET_CACHE_MMU_SIZE`.
    /// Controls whether ESP ROM needs SET cache MMU SIZE is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_needs_set_cache_mmu_size: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_NEEDS_SWSETUP_WORKAROUND`.
    /// Controls whether ESP ROM needs swsetup workaround is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_needs_swsetup_workaround: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_RAM_APP_NEEDS_MMU_INIT`.
    /// Controls whether ESP ROM RAM APP needs MMU INIT is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_ram_app_needs_mmu_init: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_SUPPORT_DEEP_SLEEP_WAKEUP_STUB`.
    /// Controls whether ESP ROM support DEEP sleep wakeup STUB is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_support_deep_sleep_wakeup_stub: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_UART_CLK_IS_XTAL`.
    /// Controls whether ESP ROM UART CLK IS XTAL is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_rom_uart_clk_is_xtal: bool = true,
    /// Kconfig key: `CONFIG_ESP_ROM_USB_OTG_NUM`.
    /// Sets the numeric value for ESP ROM USB OTG NUM in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `3`.
    esp_rom_usb_otg_num: i64 = 3,
    /// Kconfig key: `CONFIG_ESP_ROM_USB_SERIAL_DEVICE_NUM`.
    /// Sets the numeric value for ESP ROM USB serial device NUM in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `4`.
    esp_rom_usb_serial_device_num: i64 = 4,
    /// Kconfig key: `CONFIG_ESP_SPI_BUS_LOCK_ISR_FUNCS_IN_IRAM`.
    /// Controls whether ESP SPI BUS LOCK ISR funcs IN IRAM is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_spi_bus_lock_isr_funcs_in_iram: bool = true,
    /// Kconfig key: `CONFIG_ESP_TASK_WDT`.
    /// Controls whether ESP TASK WDT is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_task_wdt: bool = true,
    /// Kconfig key: `CONFIG_ESP_TASK_WDT_CHECK_IDLE_TASK_CPU0`.
    /// Controls whether ESP TASK WDT check IDLE TASK CPU0 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_task_wdt_check_idle_task_cpu0: bool = true,
    /// Kconfig key: `CONFIG_ESP_TASK_WDT_CHECK_IDLE_TASK_CPU1`.
    /// Controls whether ESP TASK WDT check IDLE TASK CPU1 is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_task_wdt_check_idle_task_cpu1: bool = true,
    /// Kconfig key: `CONFIG_ESP_TASK_WDT_EN`.
    /// Controls whether ESP TASK WDT EN is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_task_wdt_en: bool = true,
    /// Kconfig key: `CONFIG_ESP_TASK_WDT_INIT`.
    /// Controls whether ESP TASK WDT INIT is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_task_wdt_init: bool = true,
    /// Kconfig key: `CONFIG_ESP_TASK_WDT_PANIC`.
    /// Controls whether ESP TASK WDT panic is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_task_wdt_panic: bool = false,
    /// Kconfig key: `CONFIG_ESP_TASK_WDT_TIMEOUT_S`.
    /// Sets the numeric value for ESP TASK WDT timeout S in the `esp_misc` module; ESP-IDF consumes this as a size/limit/threshold parameter depending on the component.
    /// Default: `5`.
    esp_task_wdt_timeout_s: i64 = 5,
    /// Kconfig key: `CONFIG_ESP_TIME_FUNCS_USE_ESP_TIMER`.
    /// Controls whether ESP TIME funcs USE ESP timer is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_time_funcs_use_esp_timer: bool = true,
    /// Kconfig key: `CONFIG_ESP_TIME_FUNCS_USE_RTC_TIMER`.
    /// Controls whether ESP TIME funcs USE RTC timer is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_time_funcs_use_rtc_timer: bool = true,
    /// Kconfig key: `CONFIG_ESP_TLS_CLIENT_SESSION_TICKETS`.
    /// Controls whether ESP TLS client session tickets is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_tls_client_session_tickets: bool = false,
    /// Kconfig key: `CONFIG_ESP_TLS_INSECURE`.
    /// Controls whether ESP TLS insecure is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_tls_insecure: bool = false,
    /// Kconfig key: `CONFIG_ESP_TLS_PSK_VERIFICATION`.
    /// Controls whether ESP TLS PSK verification is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_tls_psk_verification: bool = false,
    /// Kconfig key: `CONFIG_ESP_TLS_SERVER_CERT_SELECT_HOOK`.
    /// Controls whether ESP TLS server CERT select HOOK is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_tls_server_cert_select_hook: bool = false,
    /// Kconfig key: `CONFIG_ESP_TLS_SERVER_MIN_AUTH_MODE_OPTIONAL`.
    /// Controls whether ESP TLS server MIN AUTH MODE optional is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_tls_server_min_auth_mode_optional: bool = false,
    /// Kconfig key: `CONFIG_ESP_TLS_SERVER_SESSION_TICKETS`.
    /// Controls whether ESP TLS server session tickets is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    esp_tls_server_session_tickets: bool = false,
    /// Kconfig key: `CONFIG_ESP_TLS_USE_DS_PERIPHERAL`.
    /// Controls whether ESP TLS USE DS peripheral is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_tls_use_ds_peripheral: bool = true,
    /// Kconfig key: `CONFIG_ESP_TLS_USING_MBEDTLS`.
    /// Controls whether ESP TLS using mbedtls is enabled for the `esp_misc` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `true`.
    esp_tls_using_mbedtls: bool = true,

    pub const default: Config = .{};

    pub fn withDefaultConfig(overrides: anytype) Config {
        return config_overrides.withDefaultConfig(Config, overrides);
    }

    pub fn appendModuleDoc(
        allocator: std.mem.Allocator,
        docs: *std.array_list.Managed(sdkconfig.ModuleDoc),
        cfg: Config,
    ) std.mem.Allocator.Error!void {
        const entries = try allocator.alloc(sdkconfig.Entry, 104);
        entries[0] = sdkconfig.Entry.flag("CONFIG_ESP_BROWNOUT_DET", cfg.esp_brownout_det);
        entries[1] = sdkconfig.Entry.int("CONFIG_ESP_BROWNOUT_DET_LVL", cfg.esp_brownout_det_lvl);
        entries[2] = sdkconfig.Entry.flag("CONFIG_ESP_BROWNOUT_DET_LVL_SEL_1", cfg.esp_brownout_det_lvl_sel_1);
        entries[3] = sdkconfig.Entry.flag("CONFIG_ESP_BROWNOUT_DET_LVL_SEL_2", cfg.esp_brownout_det_lvl_sel_2);
        entries[4] = sdkconfig.Entry.flag("CONFIG_ESP_BROWNOUT_DET_LVL_SEL_3", cfg.esp_brownout_det_lvl_sel_3);
        entries[5] = sdkconfig.Entry.flag("CONFIG_ESP_BROWNOUT_DET_LVL_SEL_4", cfg.esp_brownout_det_lvl_sel_4);
        entries[6] = sdkconfig.Entry.flag("CONFIG_ESP_BROWNOUT_DET_LVL_SEL_5", cfg.esp_brownout_det_lvl_sel_5);
        entries[7] = sdkconfig.Entry.flag("CONFIG_ESP_BROWNOUT_DET_LVL_SEL_6", cfg.esp_brownout_det_lvl_sel_6);
        entries[8] = sdkconfig.Entry.flag("CONFIG_ESP_BROWNOUT_DET_LVL_SEL_7", cfg.esp_brownout_det_lvl_sel_7);
        entries[9] = sdkconfig.Entry.flag("CONFIG_ESP_CONSOLE_NONE", cfg.esp_console_none);
        entries[10] = sdkconfig.Entry.int("CONFIG_ESP_CONSOLE_ROM_SERIAL_PORT_NUM", cfg.esp_console_rom_serial_port_num);
        entries[11] = sdkconfig.Entry.flag("CONFIG_ESP_CONSOLE_SECONDARY_NONE", cfg.esp_console_secondary_none);
        entries[12] = sdkconfig.Entry.flag("CONFIG_ESP_CONSOLE_SECONDARY_USB_SERIAL_JTAG", cfg.esp_console_secondary_usb_serial_jtag);
        entries[13] = sdkconfig.Entry.flag("CONFIG_ESP_CONSOLE_UART", cfg.esp_console_uart);
        entries[14] = sdkconfig.Entry.int("CONFIG_ESP_CONSOLE_UART_BAUDRATE", cfg.esp_console_uart_baudrate);
        entries[15] = sdkconfig.Entry.flag("CONFIG_ESP_CONSOLE_UART_CUSTOM", cfg.esp_console_uart_custom);
        entries[16] = sdkconfig.Entry.flag("CONFIG_ESP_CONSOLE_UART_DEFAULT", cfg.esp_console_uart_default);
        entries[17] = sdkconfig.Entry.flag("CONFIG_ESP_CONSOLE_UART_NONE", cfg.esp_console_uart_none);
        entries[18] = sdkconfig.Entry.int("CONFIG_ESP_CONSOLE_UART_NUM", cfg.esp_console_uart_num);
        entries[19] = sdkconfig.Entry.flag("CONFIG_ESP_CONSOLE_USB_CDC", cfg.esp_console_usb_cdc);
        entries[20] = sdkconfig.Entry.flag("CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG", cfg.esp_console_usb_serial_jtag);
        entries[21] = sdkconfig.Entry.flag("CONFIG_ESP_CONSOLE_USB_SERIAL_JTAG_ENABLED", cfg.esp_console_usb_serial_jtag_enabled);
        entries[22] = sdkconfig.Entry.flag("CONFIG_ESP_DEBUG_OCDAWARE", cfg.esp_debug_ocdaware);
        entries[23] = sdkconfig.Entry.flag("CONFIG_ESP_DEBUG_STUBS_ENABLE", cfg.esp_debug_stubs_enable);
        entries[24] = sdkconfig.Entry.int("CONFIG_ESP_DEFAULT_CPU_FREQ_MHZ", cfg.esp_default_cpu_freq_mhz);
        entries[25] = sdkconfig.Entry.flag("CONFIG_ESP_DEFAULT_CPU_FREQ_MHZ_160", cfg.esp_default_cpu_freq_mhz_160);
        entries[26] = sdkconfig.Entry.flag("CONFIG_ESP_DEFAULT_CPU_FREQ_MHZ_240", cfg.esp_default_cpu_freq_mhz_240);
        entries[27] = sdkconfig.Entry.flag("CONFIG_ESP_DEFAULT_CPU_FREQ_MHZ_80", cfg.esp_default_cpu_freq_mhz_80);
        entries[28] = sdkconfig.Entry.int("CONFIG_ESP_EFUSE_BLOCK_REV_MAX_FULL", cfg.esp_efuse_block_rev_max_full);
        entries[29] = sdkconfig.Entry.int("CONFIG_ESP_EFUSE_BLOCK_REV_MIN_FULL", cfg.esp_efuse_block_rev_min_full);
        entries[30] = sdkconfig.Entry.flag("CONFIG_ESP_ERR_TO_NAME_LOOKUP", cfg.esp_err_to_name_lookup);
        entries[31] = sdkconfig.Entry.flag("CONFIG_ESP_GRATUITOUS_ARP", cfg.esp_gratuitous_arp);
        entries[32] = sdkconfig.Entry.flag("CONFIG_ESP_INT_WDT", cfg.esp_int_wdt);
        entries[33] = sdkconfig.Entry.flag("CONFIG_ESP_INT_WDT_CHECK_CPU1", cfg.esp_int_wdt_check_cpu1);
        entries[34] = sdkconfig.Entry.int("CONFIG_ESP_INT_WDT_TIMEOUT_MS", cfg.esp_int_wdt_timeout_ms);
        entries[35] = sdkconfig.Entry.flag("CONFIG_ESP_IPC_ISR_ENABLE", cfg.esp_ipc_isr_enable);
        entries[36] = sdkconfig.Entry.int("CONFIG_ESP_IPC_TASK_STACK_SIZE", cfg.esp_ipc_task_stack_size);
        entries[37] = sdkconfig.Entry.flag("CONFIG_ESP_IPC_USES_CALLERS_PRIORITY", cfg.esp_ipc_uses_callers_priority);
        entries[38] = sdkconfig.Entry.flag("CONFIG_ESP_MAC_ADDR_UNIVERSE_BT", cfg.esp_mac_addr_universe_bt);
        entries[39] = sdkconfig.Entry.flag("CONFIG_ESP_MAC_ADDR_UNIVERSE_ETH", cfg.esp_mac_addr_universe_eth);
        entries[40] = sdkconfig.Entry.flag("CONFIG_ESP_MAC_ADDR_UNIVERSE_WIFI_AP", cfg.esp_mac_addr_universe_wifi_ap);
        entries[41] = sdkconfig.Entry.flag("CONFIG_ESP_MAC_ADDR_UNIVERSE_WIFI_STA", cfg.esp_mac_addr_universe_wifi_sta);
        entries[42] = sdkconfig.Entry.int("CONFIG_ESP_MAC_UNIVERSAL_MAC_ADDRESSES", cfg.esp_mac_universal_mac_addresses);
        entries[43] = sdkconfig.Entry.flag("CONFIG_ESP_MAC_UNIVERSAL_MAC_ADDRESSES_FOUR", cfg.esp_mac_universal_mac_addresses_four);
        entries[44] = sdkconfig.Entry.flag("CONFIG_ESP_MAC_USE_CUSTOM_MAC_AS_BASE_MAC", cfg.esp_mac_use_custom_mac_as_base_mac);
        entries[45] = sdkconfig.Entry.raw("CONFIG_ESP_MAIN_TASK_AFFINITY", cfg.esp_main_task_affinity);
        entries[46] = sdkconfig.Entry.flag("CONFIG_ESP_MAIN_TASK_AFFINITY_CPU0", cfg.esp_main_task_affinity_cpu0);
        entries[47] = sdkconfig.Entry.flag("CONFIG_ESP_MAIN_TASK_AFFINITY_CPU1", cfg.esp_main_task_affinity_cpu1);
        entries[48] = sdkconfig.Entry.flag("CONFIG_ESP_MAIN_TASK_AFFINITY_NO_AFFINITY", cfg.esp_main_task_affinity_no_affinity);
        entries[49] = sdkconfig.Entry.int("CONFIG_ESP_MAIN_TASK_STACK_SIZE", cfg.esp_main_task_stack_size);
        entries[50] = sdkconfig.Entry.int("CONFIG_ESP_MINIMAL_SHARED_STACK_SIZE", cfg.esp_minimal_shared_stack_size);
        entries[51] = sdkconfig.Entry.flag("CONFIG_ESP_MM_CACHE_MSYNC_C2M_CHUNKED_OPS", cfg.esp_mm_cache_msync_c2m_chunked_ops);
        entries[52] = sdkconfig.Entry.flag("CONFIG_ESP_PANIC_HANDLER_IRAM", cfg.esp_panic_handler_iram);
        entries[53] = sdkconfig.Entry.flag("CONFIG_ESP_PROTOCOMM_SUPPORT_SECURITY_VERSION_0", cfg.esp_protocomm_support_security_version_0);
        entries[54] = sdkconfig.Entry.flag("CONFIG_ESP_PROTOCOMM_SUPPORT_SECURITY_VERSION_1", cfg.esp_protocomm_support_security_version_1);
        entries[55] = sdkconfig.Entry.flag("CONFIG_ESP_PROTOCOMM_SUPPORT_SECURITY_VERSION_2", cfg.esp_protocomm_support_security_version_2);
        entries[56] = sdkconfig.Entry.int("CONFIG_ESP_REV_MAX_FULL", cfg.esp_rev_max_full);
        entries[57] = sdkconfig.Entry.int("CONFIG_ESP_REV_MIN_FULL", cfg.esp_rev_min_full);
        entries[58] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_GET_CLK_FREQ", cfg.esp_rom_get_clk_freq);
        entries[59] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_CACHE_SUSPEND_WAITI_BUG", cfg.esp_rom_has_cache_suspend_waiti_bug);
        entries[60] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_CACHE_WRITEBACK_BUG", cfg.esp_rom_has_cache_writeback_bug);
        entries[61] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_CRC_BE", cfg.esp_rom_has_crc_be);
        entries[62] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_CRC_LE", cfg.esp_rom_has_crc_le);
        entries[63] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_ENCRYPTED_WRITES_USING_LEGACY_DRV", cfg.esp_rom_has_encrypted_writes_using_legacy_drv);
        entries[64] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_ERASE_0_REGION_BUG", cfg.esp_rom_has_erase_0_region_bug);
        entries[65] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_ETS_PRINTF_BUG", cfg.esp_rom_has_ets_printf_bug);
        entries[66] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_FLASH_COUNT_PAGES_BUG", cfg.esp_rom_has_flash_count_pages_bug);
        entries[67] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_HAL_WDT", cfg.esp_rom_has_hal_wdt);
        entries[68] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_JPEG_DECODE", cfg.esp_rom_has_jpeg_decode);
        entries[69] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_LAYOUT_TABLE", cfg.esp_rom_has_layout_table);
        entries[70] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_MZ_CRC32", cfg.esp_rom_has_mz_crc32);
        entries[71] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_NEWLIB", cfg.esp_rom_has_newlib);
        entries[72] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_NEWLIB_32BIT_TIME", cfg.esp_rom_has_newlib_32bit_time);
        entries[73] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_NEWLIB_NANO_FORMAT", cfg.esp_rom_has_newlib_nano_format);
        entries[74] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_OUTPUT_PUTC_FUNC", cfg.esp_rom_has_output_putc_func);
        entries[75] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_RETARGETABLE_LOCKING", cfg.esp_rom_has_retargetable_locking);
        entries[76] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_SPI_FLASH", cfg.esp_rom_has_spi_flash);
        entries[77] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_SW_FLOAT", cfg.esp_rom_has_sw_float);
        entries[78] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_HAS_VERSION", cfg.esp_rom_has_version);
        entries[79] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_NEEDS_SET_CACHE_MMU_SIZE", cfg.esp_rom_needs_set_cache_mmu_size);
        entries[80] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_NEEDS_SWSETUP_WORKAROUND", cfg.esp_rom_needs_swsetup_workaround);
        entries[81] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_RAM_APP_NEEDS_MMU_INIT", cfg.esp_rom_ram_app_needs_mmu_init);
        entries[82] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_SUPPORT_DEEP_SLEEP_WAKEUP_STUB", cfg.esp_rom_support_deep_sleep_wakeup_stub);
        entries[83] = sdkconfig.Entry.flag("CONFIG_ESP_ROM_UART_CLK_IS_XTAL", cfg.esp_rom_uart_clk_is_xtal);
        entries[84] = sdkconfig.Entry.int("CONFIG_ESP_ROM_USB_OTG_NUM", cfg.esp_rom_usb_otg_num);
        entries[85] = sdkconfig.Entry.int("CONFIG_ESP_ROM_USB_SERIAL_DEVICE_NUM", cfg.esp_rom_usb_serial_device_num);
        entries[86] = sdkconfig.Entry.flag("CONFIG_ESP_SPI_BUS_LOCK_ISR_FUNCS_IN_IRAM", cfg.esp_spi_bus_lock_isr_funcs_in_iram);
        entries[87] = sdkconfig.Entry.flag("CONFIG_ESP_TASK_WDT", cfg.esp_task_wdt);
        entries[88] = sdkconfig.Entry.flag("CONFIG_ESP_TASK_WDT_CHECK_IDLE_TASK_CPU0", cfg.esp_task_wdt_check_idle_task_cpu0);
        entries[89] = sdkconfig.Entry.flag("CONFIG_ESP_TASK_WDT_CHECK_IDLE_TASK_CPU1", cfg.esp_task_wdt_check_idle_task_cpu1);
        entries[90] = sdkconfig.Entry.flag("CONFIG_ESP_TASK_WDT_EN", cfg.esp_task_wdt_en);
        entries[91] = sdkconfig.Entry.flag("CONFIG_ESP_TASK_WDT_INIT", cfg.esp_task_wdt_init);
        entries[92] = sdkconfig.Entry.flag("CONFIG_ESP_TASK_WDT_PANIC", cfg.esp_task_wdt_panic);
        entries[93] = sdkconfig.Entry.int("CONFIG_ESP_TASK_WDT_TIMEOUT_S", cfg.esp_task_wdt_timeout_s);
        entries[94] = sdkconfig.Entry.flag("CONFIG_ESP_TIME_FUNCS_USE_ESP_TIMER", cfg.esp_time_funcs_use_esp_timer);
        entries[95] = sdkconfig.Entry.flag("CONFIG_ESP_TIME_FUNCS_USE_RTC_TIMER", cfg.esp_time_funcs_use_rtc_timer);
        entries[96] = sdkconfig.Entry.flag("CONFIG_ESP_TLS_CLIENT_SESSION_TICKETS", cfg.esp_tls_client_session_tickets);
        entries[97] = sdkconfig.Entry.flag("CONFIG_ESP_TLS_INSECURE", cfg.esp_tls_insecure);
        entries[98] = sdkconfig.Entry.flag("CONFIG_ESP_TLS_PSK_VERIFICATION", cfg.esp_tls_psk_verification);
        entries[99] = sdkconfig.Entry.flag("CONFIG_ESP_TLS_SERVER_CERT_SELECT_HOOK", cfg.esp_tls_server_cert_select_hook);
        entries[100] = sdkconfig.Entry.flag("CONFIG_ESP_TLS_SERVER_MIN_AUTH_MODE_OPTIONAL", cfg.esp_tls_server_min_auth_mode_optional);
        entries[101] = sdkconfig.Entry.flag("CONFIG_ESP_TLS_SERVER_SESSION_TICKETS", cfg.esp_tls_server_session_tickets);
        entries[102] = sdkconfig.Entry.flag("CONFIG_ESP_TLS_USE_DS_PERIPHERAL", cfg.esp_tls_use_ds_peripheral);
        entries[103] = sdkconfig.Entry.flag("CONFIG_ESP_TLS_USING_MBEDTLS", cfg.esp_tls_using_mbedtls);

        try docs.append(.{
            .name = module_name,
            .entries = entries,
        });
    }
};
