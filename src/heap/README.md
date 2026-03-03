# heap

Sdkconfig binding and runtime API for the ESP-IDF `heap` component.

## ESP-IDF component

Maps to [`heap`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/system/mem_alloc.html).

## Module boundary

Provides sdkconfig bindings for heap memory management: poisoning modes, tracing, task tracking, allocation-failure behavior, and flash placement.

Also exposes a **runtime API** via `root.zig`:
- `freeHeapSize()` — returns current free heap bytes.
- `minimumFreeHeapSize()` — returns minimum free heap watermark since boot.
- `freeInternalHeapSize()` — returns free internal (non-PSRAM) heap bytes.

The module is registered with `zig_root` so firmware can `@import("heap")`.

## Dependencies

- ESP-IDF `heap` component (via `idf_requires`).
