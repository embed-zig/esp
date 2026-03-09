# esp_system

Sdkconfig binding and logging API for the ESP-IDF `esp_system` component.

## ESP-IDF component

Maps to [`esp_system`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/system/esp_system.html).

## Module boundary

Core system module (config module_name: `"core"`). Provides sdkconfig bindings for partition table, panic handling, log level, brownout detection, watchdog timers, memory protection, IPC, and main task configuration. Also exposes a minimal `log` API (`info`/`warn`/`err`) with injectable sink for testing.

The `config.zig` uses enum fields (`PanicMode`, `LogDefaultLevel`) that expand into multiple Kconfig choice keys in `appendModuleDoc` — 38 config fields produce 48 sdkconfig entries (including hardcoded flags and legacy aliases).

## Dependencies

No runtime dependencies beyond `std`.
