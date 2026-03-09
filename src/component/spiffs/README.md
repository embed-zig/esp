# spiffs

Runtime and sdkconfig binding for the ESP-IDF `spiffs` component.

## ESP-IDF component

Maps to [`spiffs`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/storage/spiffs.html).

## Module boundary

Provides:
- Sdkconfig options for the SPIFFS filesystem (page/block/object sizes, GC tuning, cache, debug logging, integrity checks).
- Runtime Zig API for mounting/unmounting SPIFFS partitions via VFS and querying usage info.

## Dependencies

- `spiffs` (ESP-IDF component)
- `esp_partition` (ESP-IDF component)
