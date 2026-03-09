# nvs_flash

Maps to ESP-IDF component: `nvs_flash`.

## Boundary

Provides Zig wrappers for NVS flash lifecycle management and key-value storage via C shims (`espz_nvs_*`).

## Runtime API

### Partition lifecycle

- `init()` — initialize NVS partition.
- `deinit()` — deinitialize NVS.
- `erase()` — erase NVS partition.

### Namespace key-value operations

- `Namespace.open(name)` — open a namespace for read/write.
- `Namespace.close()` — close namespace handle.
- `Namespace.getU32(key)` / `Namespace.setU32(key, value)` — unsigned 32-bit integer.
- `Namespace.getI32(key)` / `Namespace.setI32(key, value)` — signed 32-bit integer.
- `Namespace.getString(key, buf)` / `Namespace.setString(key, value)` — blob/string data.
- `Namespace.erase(key)` — erase a single key.
- `Namespace.eraseAll()` — erase all keys in namespace.
- `Namespace.commit()` — persist pending writes.

The module is registered with `zig_root` so firmware can `@import("nvs_flash")`.

## Dependencies

- ESP-IDF: `nvs_flash` (via `idf_requires`)
- No other espz modules
