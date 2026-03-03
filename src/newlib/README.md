# newlib

Maps to ESP-IDF component: `newlib`.

## Boundary

Exposes C runtime symbols needed by Zig firmware. Currently only `abort`. Does not cover malloc, printf, or other libc APIs (use std or esp_rom).

## Runtime API

- `abort()` — terminate process (noreturn)

## Dependencies

- ESP-IDF: `newlib`
- No other espz modules
