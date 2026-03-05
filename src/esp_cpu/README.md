# esp_cpu

Runtime API for CPU/system core metadata helpers.

## ESP-IDF component

Backed by `esp_hw_support` (`esp_cpu_get_core_count`).

## Module boundary

Exposes:
- `getCoreCount()` — returns available core count.

The module is registered with `zig_root` so firmware can `@import("esp_cpu")`.

## Dependencies

- ESP-IDF `esp_hw_support` component (via `idf_requires`).
