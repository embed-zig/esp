# app_metadata

Sdkconfig binding for ESP-IDF application build metadata and versioning.

## ESP-IDF component

Maps to [`app_update`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/system/app_image_format.html) and project-level build configuration.

## Module boundary

Typed sdkconfig definitions for application build type, binary generation, version embedding, reproducible builds, and OTA rollback settings. No runtime Zig API.

## Dependencies

No runtime dependencies.
