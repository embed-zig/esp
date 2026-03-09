# esp_driver_spi

Zig binding for the ESP-IDF SPI master driver.

## ESP-IDF component

Maps to [`esp_driver_spi`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/peripherals/spi_master.html) (master mode).

## Module boundary

Provides a struct-based `SpiMaster` API:
- `init` / `deinit` — bus + device lifecycle (one device per host).
- `write` — transmit-only transfer.
- `read` — receive-only transfer.
- `transfer` — full-duplex transfer.

C shim (`c_helper.c`) manages a static device-handle table indexed by host ID.
Callers must ensure the same host ID is not accessed concurrently from multiple tasks.

Does **not** cover slave mode, multi-device-per-bus, or DMA descriptor chaining.

The module is registered with `zig_root` so firmware can `@import("esp_driver_spi")`.

## Dependencies

- ESP-IDF `driver` and `esp_driver_spi` components (via `idf_requires`).
