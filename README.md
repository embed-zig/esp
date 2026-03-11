# ESP

Zig-first ESP-IDF bindings for writing ESP32 firmware in pure Zig.

[中文 README](./README.zh-CN.md)

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
cd examples/hello_world
zig build idf-build \
  -Dbuild_config=board/esp32s3_devkit/build_config.zig \
  -Dbsp=board/esp32s3_devkit/bsp.zig \
  -Desp_idf=/path/to/esp-idf
```

Or use the environment manually:

```bash
export ESP_IDF=/path/to/esp-idf
source "$ESP_IDF/export.sh"
```

## Quick start

```bash
cd examples/hello_world
zig build flash-monitor \
  -Dbuild_config=board/esp32s3_devkit/build_config.zig \
  -Dbsp=board/esp32s3_devkit/bsp.zig \
  -Dport=/dev/cu.usbmodem1301 \
  -Desp_idf="$ESP_IDF" \
  -Dtimeout=15
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

Examples require both `-Dbuild_config=...` and `-Dbsp=...`.

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
zig build hello_world \
  -Dbuild_config=examples/hello_world/board/esp32s3_devkit/build_config.zig \
  -Dbsp=examples/hello_world/board/esp32s3_devkit/bsp.zig
zig build wifi_scan \
  -Dbuild_config=examples/wifi/scan/board/esp32s3_devkit/build_config.zig \
  -Dbsp=examples/wifi/scan/board/esp32s3_devkit/bsp.zig
zig build bt_vhci_smoke \
  -Dbuild_config=examples/bt_vhci_smoke/board/esp32s3_devkit/build_config.zig \
  -Dbsp=examples/bt_vhci_smoke/board/esp32s3_devkit/bsp.zig
```

Example workflow commands:

```bash
zig build <app>-configure -Dbuild_config=<path> -Dbsp=<path> -Desp_idf=/path/to/esp-idf
zig build <app>-idf-build -Dbuild_config=<path> -Dbsp=<path> -Desp_idf=/path/to/esp-idf
zig build <app>-flash -Dbuild_config=<path> -Dbsp=<path> -Dport=/dev/cu.xxx -Desp_idf=/path/to/esp-idf
zig build <app>-monitor -Dbuild_config=<path> -Dbsp=<path> -Dport=/dev/cu.xxx -Desp_idf=/path/to/esp-idf
zig build <app>-flash-monitor -Dbuild_config=<path> -Dbsp=<path> -Dport=/dev/cu.xxx -Desp_idf=/path/to/esp-idf
```

## Build options

Common options:

- `-Dbuild_config=<path>`: required board config file
- `-Dbsp=<path>`: required board BSP file
- `-Dbuild_dir=<dir>`: generated build output directory
- `-Desp_idf=<path>`: ESP-IDF root
- `-Didf_py=<path>`: explicit `idf.py`
- `-Dport=<serial>`: serial port for flash and monitor
- `-Dbaud=<rate>`: serial baud rate
- `-Dtimeout=<seconds>`: auto-exit monitor after N seconds
