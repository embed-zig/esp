# wifi_scan

External Zig package example consuming `espz` workflow.

## Source layout

- `src/main.zig`: Zig-side entry logic
- `build.zig`: workflow registration
- `board/*.zig`: board profile files

This example keeps **no hand-written IDF CMake project files** and **no hand-written C sources** under `examples/wifi/scan/`.
The workflow generates a temporary IDF project under `build_dir` automatically.

## Build (inside this directory)

```bash
cd examples/wifi/scan
zig build wifi_scan
```

## IDF workflow (inside this directory)

Set `ESP_IDF` in environment, or pass `-Desp_idf=/path/to/esp-idf`.

```bash
cd examples/wifi/scan
zig build wifi_scan-sdkconfig -Dboard=board/esp32s3_devkit.zig
zig build wifi_scan-idf-build -Dboard=board/esp32s3_devkit.zig
zig build wifi_scan-flash -Dboard=board/esp32s3_devkit.zig -Dport=/dev/<serial-port>
zig build wifi_scan-monitor -Dboard=board/esp32s3_devkit.zig -Dport=/dev/<serial-port>
```

## Generated files (under `build_dir`)

- `sdkconfig.generated`
- `partitions.generated.<hash>.csv`
- `idf/` (IDF build directory)
- `idf_project/` (temporary generated CMake project)
