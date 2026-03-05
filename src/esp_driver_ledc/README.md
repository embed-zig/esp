# esp_driver_ledc

Sdkconfig binding and runtime Zig API for the ESP-IDF `esp_driver_ledc` component.

## ESP-IDF component

Maps to [`esp_driver_ledc`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/peripherals/ledc.html).

## Module boundary

Typed sdkconfig definitions for LEDC control function IRAM placement.

Provides runtime Zig bindings for LEDC timer/channel configuration and duty/fade control through thin C shims.

### Runtime API

- `Ledc.init(cfg)` — configure timer + channel + optional fade service in one call
- `configureTimer(cfg)` — configure LEDC timer
- `configureChannel(cfg)` — configure LEDC channel
- `setDuty(mode, channel, duty)` — set raw duty and update
- `setDutyPercentWithResolution(mode, channel, bits, percent)` — set duty by percentage
- `installFadeService()` — install fade service once
- `fadeToDuty(mode, channel, duty, duration_ms, wait_done)` — fade to raw duty
- `fadeToPercentWithResolution(mode, channel, bits, percent, duration_ms, wait_done)` — fade by percentage

Note: `speed_mode` defaults to `0` in all config structs. On ESP32-S3 this is the only valid mode. On classic ESP32, pass `1` for low-speed mode explicitly.

## Dependencies

- ESP-IDF: `esp_driver_ledc`
- No other espz module dependencies.
