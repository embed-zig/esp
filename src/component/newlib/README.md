# newlib

Maps to ESP-IDF component: `newlib`.

## Boundary

Exposes C runtime symbols needed by Zig firmware. Does not cover malloc, printf, or other libc APIs (use std or esp_rom).

Raw `extern fn` is used instead of C shims because these are fundamental POSIX/libc symbols with a stable ABI.

## Runtime API

- `abort()` — terminate process (noreturn).
- `fs.openFile(path, flags)` — open a file, returns fd.
- `fs.closeFile(fd)` — close a file descriptor.
- `fs.readFile(fd, buf)` — read bytes from fd.
- `fs.writeFile(fd, buf)` — write bytes to fd.
- `fs.fileSize(fd)` — query file size via fstat.
- `fs.seekEnd(fd)` / `fs.seekBegin(fd)` — seek to end or beginning.
- `fs.deleteFile(path)` — unlink a file.
- `fs.renameFile(old, new)` — rename a file.

The module is registered with `zig_root` so firmware can `@import("newlib")`.

## Dependencies

- ESP-IDF: `newlib`
- No other espz modules
