# app_metadata

Sdkconfig binding and OTA runtime API for ESP-IDF application build metadata and versioning.

## ESP-IDF component

Maps to [`app_update`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/system/app_image_format.html) and project-level build configuration.

## Module boundary

Typed sdkconfig definitions for application build type, binary generation, version embedding, reproducible builds, and OTA rollback settings.

Also provides a runtime OTA API (`ota.zig`) via C shims (`espz_ota_*`):

### Runtime API

- `getNextUpdatePartition()` — find next OTA partition.
- `getRunningPartition()` — get currently running partition.
- `begin(partition, image_size)` — start OTA write session.
- `write(handle, data)` — write firmware image data.
- `end(handle)` — finalize OTA write.
- `abort(handle)` — abort OTA session.
- `setBootPartition(partition)` — set boot partition for next reboot.
- `getPartitionState(partition)` — query OTA partition state.
- `markValid()` — confirm current app, cancel rollback.
- `markInvalidAndRollback()` — mark app invalid and trigger rollback reboot.

## Dependencies

- ESP-IDF: `app_update`, `esp_ota_ops` (via `idf_requires`).
