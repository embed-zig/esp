# esp_rom

Maps to ESP-IDF component: `esp_rom`.

## Boundary

Exposes ROM printf for early/debug output. Does not cover other ROM utilities (e.g. ets_delay, chip-specific ROM APIs).

## Runtime API

- `printf(format, args...)` — variadic printf via ROM (no heap)
- `esp_rom_printf` — raw extern for C interop

## Dependencies

- ESP-IDF: `esp_rom`
- No other espz modules
