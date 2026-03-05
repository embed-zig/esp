# ESPZ

Zig-first ESP-IDF binding package. Write ESP32 firmware in pure Zig with
type-safe APIs, declarative board configs, and zero hand-written CMake.

## Prerequisites

- **Zig toolchain**: use the Xtensa-capable fork from
  [embed-zig/esp-zig-bootstrap](https://github.com/embed-zig/esp-zig-bootstrap)
  (>= 0.15.2). Upstream Zig does not support Xtensa.
- **ESP-IDF** (v5.x): required for flash/monitor workflows.

```bash
export ESP_IDF=/path/to/esp-idf
source "$ESP_IDF/export.sh"
```

## Quick start

```bash
cd examples/hello_world
zig build flash-monitor \
  -Dboard=board/esp32s3_devkit.zig \
  -Dport=/dev/cu.usbmodem1301 \
  -Desp_idf=$ESP_IDF \
  -Dtimeout=15
```

## Repository layout

```text
.
├── build.zig              # Root package: exports workflow + registerApp
├── src/
│   ├── component.zig      # Firmware runtime entry (re-exports modules with Zig API)
│   ├── cmake.zig          # CMake build pipeline (aggregates embedded C shims)
│   ├── sdkconfig.zig      # Sdkconfig generation pipeline (aggregates config modules)
│   ├── esp_lcd/           # Component binding: Zig API + C shim + metadata
│   │   ├── root.zig       # Single entry: runtime API + embedded_files + idf_requires
│   │   ├── panel.zig      # Panel type (reset/init/draw/mirror/...)
│   │   ├── spi.zig        # SPI Bus + PanelIo types
│   │   ├── driver.zig     # ST7789 / ILI9341 driver creation
│   │   ├── c_helper.c     # C shim: bridges extern fn to ESP-IDF C API
│   │   └── c_helper.h
│   ├── esp_driver_i2c/    # I2C master shim
│   ├── esp_driver_ledc/   # LEDC backlight shim
│   ├── esp_adc/           # ADC oneshot shim
│   └── ...                # Other component modules (sdkconfig-only or with runtime API)
├── idf/
│   ├── build/             # Build workflow (scaffold, env check, pty monitor)
│   ├── sdkconfig/         # Sdkconfig generation system
│   └── partition/         # Partition table generation
└── examples/
    ├── hello_world/       # Minimal pure-Zig blinky
    ├── lcd_battery/       # LCD + battery ADC (pure Zig, uses esp_lcd module)
    ├── wifi/              # Wi-Fi scan/sta/ap examples
    └── bt_vhci_smoke/     # Bluetooth VHCI smoke test
```

## How it works

### Component bindings (`src/<module>/`)

Each module maps 1:1 to an ESP-IDF component. A `root.zig` serves as the single
entry point, exporting:

- **Runtime Zig API** — type-safe wrappers around extern FFI functions
  (e.g. `Panel`, `Bus`, `PanelIo`).
- **Embedded C shims** — `c_helper.c` files that bridge Zig extern declarations
  to ESP-IDF C APIs with complex struct parameters. Embedded via `@embedFile`
  and auto-released to the build directory.
- **Build metadata** — `module_name`, `idf_requires`, `zig_root` used by the
  scaffold generator to wire CMake and Zig module deps.

Register a new module with one line in `src/cmake.zig`.

### Firmware examples (`examples/<app>/`)

A firmware project consists of three files:

| File | Purpose |
|---|---|
| `build.zig` | Calls `espz.registerApp()` — no CMake, no boilerplate |
| `board/<name>.zig` | `pub const config` (sdkconfig) + `pub const pins` (hardware pin layout) |
| `src/main.zig` | Pure Zig firmware — `@import("esp_lcd")` for APIs, `@import("board_pins")` for pin config |

The framework auto-injects module deps and board config based on `-Dboard=`.
Build commands are identical across all examples:

```bash
zig build flash-monitor -Dboard=board/esp32s3_szp.zig -Dport=/dev/cu.xxx -Dtimeout=15
```

### Build pipeline

```text
zig build flash-monitor
  ├─ sdkconfig generation       (board/*.zig → sdkconfig.generated)
  ├─ IDF project scaffold       (CMakeLists.txt + app_main.c + espz_rt/ C shims)
  ├─ Zig static library          (src/main.zig → zig_entry.a, with --dep esp_lcd/board_pins)
  ├─ ESP-IDF CMake build         (idf.py build)
  ├─ Flash                       (esptool)
  └─ Monitor                     (idf_monitor via pty, auto-exit with -Dtimeout)
```

## Build options

| Option | Description |
|---|---|
| `-Dboard=<path>` | Board profile file (default varies per example) |
| `-Dbuild_dir=<dir>` | Build output directory (default: `build`) |
| `-Desp_idf=<path>` | ESP-IDF root (or set `ESP_IDF` env var) |
| `-Dport=<serial>` | Serial port for flash/monitor |
| `-Dtimeout=<seconds>` | Auto-exit monitor after N seconds |
| `-Dzig_bin=<path>` | Zig binary for cross-compilation |

## Design principles

- **ESP-IDF bindings only** — no cross-platform abstraction layer.
- **Pure Zig firmware** — no C business code in examples; C shims live in component modules.
- **Single entry per module** — `root.zig` is the only export surface.
- **Board config as data** — pins and sdkconfig are declarative structs, not code.
- **Zero user-facing CMake** — all CMakeLists.txt are auto-generated.
