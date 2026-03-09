# pthread

Sdkconfig binding for the ESP-IDF `pthread` component.

## ESP-IDF component

Maps to [`pthread`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/system/pthread.html).

## Module boundary

Provides sdkconfig options for POSIX threads on ESP-IDF: default stack size, core affinity, priority, and detach state. No runtime Zig API.

## Dependencies

No runtime dependencies.
