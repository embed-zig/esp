# esp_random

Sdkconfig/runtime-facing API for ESP-IDF random number generation.

## ESP-IDF component

Backed by `esp_hw_support` (`esp_fill_random`).

## Module boundary

Exposes a small runtime API:
- `fill(buf)` — fills a byte slice with hardware random data.

The module is registered with `zig_root` so firmware can `@import("esp_random")`.

## Dependencies

- ESP-IDF `esp_hw_support` component (via `idf_requires`).
