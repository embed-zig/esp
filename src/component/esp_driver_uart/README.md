# esp_driver_uart

Sdkconfig binding and runtime Zig API for the ESP-IDF `esp_driver_uart` component.

## ESP-IDF component

Maps to [`esp_driver_uart`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/peripherals/uart.html).

## Module boundary

Typed sdkconfig definitions for the UART peripheral driver. Also provides a runtime API for basic UART I/O via C shims (`espz_uart_*`).

### Runtime API

- `init(Config)` — configure and install UART driver (baud rate, pins, buffer sizes).
- `deinit(port)` — uninstall UART driver.
- `read(port, buf, timeout_ms)` — read bytes from UART RX buffer.
- `write(port, data, timeout_ms)` — write bytes to UART TX.
- `bufferedLen(port)` — query number of bytes buffered in RX.

The module is registered with `zig_root` so firmware can `@import("esp_driver_uart")`.

## Dependencies

- ESP-IDF: `driver`, `esp_driver_uart` (via `idf_requires`).
