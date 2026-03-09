# partition_table

Sdkconfig binding for the ESP-IDF `partition_table` component.

## ESP-IDF component

Maps to [`partition_table`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/storage/partition.html).

## Module boundary

Provides sdkconfig options for flash partition layout: custom vs. predefined tables, partition CSV filename, MD5 checksums, and two-OTA-slot configuration. No runtime Zig API.

## Dependencies

No runtime dependencies.
