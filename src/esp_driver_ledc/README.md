# esp_driver_ledc

Sdkconfig binding and runtime Zig API for the ESP-IDF `esp_driver_ledc` component.

## ESP-IDF component

Maps to [`esp_driver_ledc`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/peripherals/ledc.html).

## Module boundary

Typed sdkconfig definitions for LEDC control function IRAM placement. Provides a runtime Zig API for LEDC backlight control via C shims: PWM channel initialization and duty cycle percentage setting.

### Runtime API

- `backlightInit(gpio, channel, freq, invert)` — initialize LEDC for backlight PWM
- `setDutyPercent(channel, percent)` — set duty cycle (0-100%)

## Dependencies

- ESP-IDF: `esp_driver_ledc`
- No other espz module dependencies.
