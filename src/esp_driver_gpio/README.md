# esp_driver_gpio

Zig binding for the ESP-IDF GPIO driver.

## ESP-IDF component

Maps to [`esp_driver_gpio`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-reference/peripherals/gpio.html).

## Module boundary

Provides a thin runtime API over basic GPIO operations:
- `setDirection` — configure pin as input, output, or open-drain.
- `setLevel` / `getLevel` — write / read digital level.
- `setPullMode` — configure internal pull-up / pull-down resistors.
- `resetPin` — reset a pin to default state.

Does **not** cover GPIO interrupt registration or GPIO bundle APIs.

The module is registered with `zig_root` so firmware can `@import("esp_driver_gpio")`.

## Dependencies

- ESP-IDF `esp_driver_gpio` component (via `idf_requires`).
