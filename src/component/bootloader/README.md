# bootloader

Sdkconfig binding for the ESP-IDF `bootloader` component.

## ESP-IDF component

Maps to [`bootloader`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/system/bootloader.html).

## Module boundary

Typed sdkconfig definitions for second-stage bootloader behavior: compiler optimization, logging, watchdog timer, flash offset, image validation, factory reset, VDDSDIO boost, and ROM log control. No runtime Zig API.

## Dependencies

No runtime dependencies.
