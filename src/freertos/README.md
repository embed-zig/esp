# freertos

Sdkconfig binding and runtime API for the ESP-IDF `freertos` component.

## ESP-IDF component

Maps to [`freertos`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/system/freertos_idf.html).

## Module boundary

Provides sdkconfig bindings for FreeRTOS scheduler configuration: tick rate, core count (SMP/unicore), stack sizes, timer service, stack overflow detection, and task debugging options.

Also exposes a **runtime API** via `task.zig`:
- `delay(ticks)` — delays the calling task for the given tick count (wraps `vTaskDelay`).
- `msToTicks(ms, tick_rate_hz)` — converts milliseconds to tick count with floor semantics.
- `TickType` — tick counter type alias (`u32`).

The module is registered with `zig_root` so firmware can `@import("freertos")`.

## Dependencies

- ESP-IDF `freertos` component (via `idf_requires`).
