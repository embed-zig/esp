# spiffs

Sdkconfig binding for the ESP-IDF `spiffs` component.

## ESP-IDF component

Maps to [`spiffs`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/storage/spiffs.html).

## Module boundary

Provides sdkconfig options for the SPIFFS filesystem: page/block/object sizes, GC tuning, cache configuration, debug logging, and integrity checks. No runtime Zig API.

## Dependencies

No runtime dependencies.
