# ESP

Zig-first ESP-IDF bindings for writing ESP32 firmware in pure Zig.

## Table Of Contents
- [Prerequisites](#prerequisites)
- [Quick start](#quick-start)
- [Repository layout](#repository-layout)
- [Core concepts](#core-concepts)
- [Common commands](#common-commands)
- [Build options](#build-options)

## Prerequisites

- Zig: use the Xtensa-capable fork from [embed-zig/esp-zig-bootstrap](https://github.com/embed-zig/esp-zig-bootstrap)
- ESP-IDF v5.x

Recommended:

```bash
zig build hello_world-idf-build -Desp_idf=/path/to/esp-idf
```

Or use the environment manually:

```bash
export ESP_IDF=/path/to/esp-idf
source "$ESP_IDF/export.sh"
```

## Quick start

```bash
cd examples/hello_world
zig build flash-monitor -Dport=/dev/cu.usbmodem1301 -Desp_idf="$ESP_IDF" -Dtimeout=15
```

## Repository layout

```text
.
├── build.zig
├── src/
│   ├── esp_mod.zig          # root Zig API: esp.component / esp.hal / esp.runtime
│   ├── idf_mod.zig          # root IDF helpers: sdkconfig / partition / build
│   ├── component/           # 1:1 ESP-IDF component bindings
│   ├── hal/                 # board-facing hardware abstractions
│   ├── runtime/             # reusable runtime helpers
│   └── idf/                 # build, sdkconfig, partition integration
├── test/
│   ├── convention_checks.zig
│   └── compile_test/
└── examples/
    ├── hello_world/
    ├── wifi/
    ├── bt_vhci_smoke/
    ├── aec_7210_8311/
    └── ota_led/
```

## Core concepts

### Component bindings

Each directory under `src/component/` maps to one ESP-IDF component.

- `esp_mod.zig`: runtime Zig API
- `idf_mod.zig`: build metadata and sdkconfig export
- `sdkconfig.zig`: owned config surface
- `c_helper.c` / `c_helper.h`: optional thin C shims

### Firmware examples

Examples live under `examples/<app>/` and usually contain:

- `build.zig`
- `board/`
- `src/main.zig`

Most examples accept `-Dbuild_config=...` and optional `-Dbsp=...`. Some apps
require both explicitly.

### Build flow

`zig build` drives the whole pipeline:

1. Generate sdkconfig and partition data from board config
2. Scaffold a temporary IDF project
3. Build Zig firmware as a static library
4. Run `idf.py build`
5. Optionally flash and monitor

## Common commands

```bash
zig build
zig build test
zig build -l
```

Build one example:

```bash
zig build hello_world
zig build wifi_scan
zig build bt_vhci_smoke
```

Example workflow commands:

```bash
zig build <app>-configure -Desp_idf=/path/to/esp-idf
zig build <app>-idf-build -Desp_idf=/path/to/esp-idf
zig build <app>-flash -Dport=/dev/cu.xxx -Desp_idf=/path/to/esp-idf
zig build <app>-monitor -Dport=/dev/cu.xxx -Desp_idf=/path/to/esp-idf
zig build <app>-flash-monitor -Dport=/dev/cu.xxx -Desp_idf=/path/to/esp-idf
```

## Build options

Common options:

- `-Dbuild_config=<path>`: board config file
- `-Dbsp=<path>`: board BSP file for examples that split config and BSP
- `-Dbuild_dir=<dir>`: generated build output directory
- `-Desp_idf=<path>`: ESP-IDF root
- `-Didf_py=<path>`: explicit `idf.py`
- `-Dport=<serial>`: serial port for flash and monitor
- `-Dbaud=<rate>`: serial baud rate
- `-Dtimeout=<seconds>`: auto-exit monitor after N seconds
