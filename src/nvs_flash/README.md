# nvs_flash

Maps to ESP-IDF component: `nvs_flash`.

## Boundary

Provides Zig wrappers for NVS flash init, deinit, and erase. Does not cover key-value read/write or NVS namespaces.

## Runtime API

- `init()` — initialize NVS partition
- `deinit()` — deinitialize NVS
- `erase()` — erase NVS partition

## Dependencies

- ESP-IDF: `nvs_flash`
- No other espz modules
