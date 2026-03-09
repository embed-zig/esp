# esp_driver_i2c

Sdkconfig binding and runtime Zig API for the ESP-IDF `esp_driver_i2c` component.

## ESP-IDF component

Maps to [`esp_driver_i2c`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/peripherals/i2c.html).

## Module boundary

Typed sdkconfig definitions for I2C debug logging, slave driver version, and ISR IRAM safety. Provides a runtime Zig API for I2C master mode via C shims: bus initialization, write-to-device, and combined write-read transactions.

### Runtime API

- `I2cMaster.init(Config)` — initialize I2C master bus (port, SDA, SCL, frequency).
- `I2cMaster.write(addr, data, timeout_ms)` — write to device.
- `I2cMaster.writeRead(addr, write_data, read_data, timeout_ms)` — combined write-then-read.

## Dependencies

- ESP-IDF: `driver`, `esp_driver_i2c`
- No other espz module dependencies.
