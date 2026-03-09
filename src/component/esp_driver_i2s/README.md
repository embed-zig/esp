# esp_driver_i2s

Sdkconfig binding and runtime Zig API for the ESP-IDF `esp_driver_i2s` component.

## ESP-IDF component

Maps to [`esp_driver_i2s`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/peripherals/i2s.html).

## Module boundary

Typed sdkconfig definitions for I2S driver options (debug log, ISR IRAM safety, deprecation warnings).

Provides runtime Zig bindings for I2S in three operating modes:

### Simplex RX (`I2sRx`)

Receive-only channel. Supports standard (Philips/MSB) and TDM modes.

- `init(RxConfig)` / `deinit()`
- `read(buf, timeout_ms)` / `readI16(buf, timeout_ms)`

### Simplex TX (`I2sTx`)

Transmit-only channel. Supports standard and TDM modes.

- `init(TxConfig)` / `deinit()`
- `write(buf, timeout_ms)` / `writeI16(buf, timeout_ms)`

### Full-duplex (`I2sDuplex`)

RX + TX on the same I2S port, allocated in a single `i2s_new_channel` call so they share BCLK/WS clocks. Required when both directions use the same port (e.g. ES7210 ADC capture + ES8311 DAC playback for AEC).

- `init(DuplexConfig)` / `deinit()`
- `read` / `readI16` (RX side)
- `write` / `writeI16` (TX side)

## Dependencies

- ESP-IDF: `driver`, `esp_driver_i2s`
- No other espz module dependencies.
