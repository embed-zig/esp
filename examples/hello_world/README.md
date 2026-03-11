# hello_world

## 简介

最小纯 Zig 固件示例，启动后持续打印心跳日志。

## 功能

- 最小化 Zig 固件入口
- 周期性打印心跳日志

## 构建与烧录

```bash
cd examples/hello_world
zig build flash-monitor -Dbuild_config=board/esp32s3_devkit/build_config.zig -Dbsp=board/esp32s3_devkit/bsp.zig -Dport=/dev/cu.usbmodem1301 -Desp_idf=$ESP_IDF -Dtimeout=15
```
当前示例已切换到拆分式 board 目录，因此需要同时传入 `-Dbuild_config` 与 `-Dbsp`。

## 运行结果

**测试日期**: 2026-03-03 | **开发板**: ESP32-S3 DevKit

| 固件 | 大小 |
|------|------|
| bootloader | 21,008 bytes (0x5210) |
| partition-table | 3,072 bytes |
| hello_world.bin | 206,416 bytes (0x32650) |

| 内存 | 数值 |
|------|------|
| free heap | 390,340 |
| min free heap | 390,340 |

## 源码结构

- `src/main.zig` — 应用逻辑
- `build.zig` — 构建配置
- `board/esp32s3_devkit/build_config.zig` — DevKit build-time sdkconfig profile
- `board/esp32s3_devkit/bsp.zig` — DevKit runtime board module
- `board/esp32s3_krovo2/build_config.zig` — Krovo2 build-time sdkconfig profile
- `board/esp32s3_krovo2/bsp.zig` — Krovo2 runtime board module
- `board/esp32s3_szp/build_config.zig` — SZP build-time sdkconfig profile
- `board/esp32s3_szp/bsp.zig` — SZP runtime board module
