# wifi_scan

External Zig package example consuming `espz` workflow.

## Source layout

- `src/main.zig`: Zig-side entry logic
- `build.zig`: workflow registration
- `board/<name>/build_config.zig`: build-time sdkconfig profile
- `board/<name>/bsp.zig`: runtime board module

This example keeps **no hand-written IDF CMake project files** and **no hand-written C sources** under `examples/wifi/scan/`.
The workflow generates a temporary IDF project under `build_dir` automatically.
This example now uses the split board layout, so both `-Dbuild_config` and `-Dbsp` are required.

## Build (inside this directory)

```bash
cd examples/wifi/scan
zig build build -Dbuild_config=board/esp32s3_devkit/build_config.zig -Dbsp=board/esp32s3_devkit/bsp.zig -Desp_idf=/path/to/esp-idf
```

## IDF workflow (inside this directory)

Set `ESP_IDF` in environment, or pass `-Desp_idf=/path/to/esp-idf`.

```bash
cd examples/wifi/scan
zig build generate-sdkconfig -Dbuild_config=board/esp32s3_devkit/build_config.zig -Dbsp=board/esp32s3_devkit/bsp.zig
zig build build -Dbuild_config=board/esp32s3_devkit/build_config.zig -Dbsp=board/esp32s3_devkit/bsp.zig -Desp_idf=/path/to/esp-idf
zig build flash -Dbuild_config=board/esp32s3_devkit/build_config.zig -Dbsp=board/esp32s3_devkit/bsp.zig -Dport=/dev/<serial-port> -Desp_idf=/path/to/esp-idf
zig build monitor -Dbuild_config=board/esp32s3_devkit/build_config.zig -Dbsp=board/esp32s3_devkit/bsp.zig -Dport=/dev/<serial-port> -Desp_idf=/path/to/esp-idf
```

## Generated files (under `build_dir`)

- `sdkconfig.generated`
- `partitions.generated.<hash>.csv`
- `idf/` (IDF build directory)
- `idf_project/` (temporary generated CMake project)
