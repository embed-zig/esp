# wifi_sta

## 简介

Wi-Fi STA 示例。扫描周围 AP、连接指定热点、获取 DHCP IP 和 MAC 地址。

## 功能

- Wi-Fi 扫描（显示 SSID/RSSI/channel）
- STA 连接（WPA2-PSK）
- DHCP 获取 IP
- MAC 地址查询

## 构建与烧录

```bash
cd examples/wifi/sta
zig build flash-monitor -Dbuild_config=board/esp32s3_devkit/build_config.zig -Dbsp=board/esp32s3_devkit/bsp.zig -Dport=/dev/cu.usbmodem1301 -Desp_idf=$ESP_IDF -Dtimeout=15
```
当前示例已切换到拆分式 board 目录，因此需要同时传入 `-Dbuild_config` 与 `-Dbsp`。

## 运行结果

**测试日期**: 2026-03-03 | **开发板**: ESP32-S3 DevKit

| 固件 | 大小 |
|------|------|
| bootloader | 21,008 bytes (0x5210) |
| partition-table | 3,072 bytes |
| wifi_sta.bin | 767,600 bytes (0xBB670) |

| 内存 | 数值 |
|------|------|
| free heap | 333,908 |
| min free heap | 333,908 |

## 源码结构

- `src/main.zig` — 应用逻辑
- `build.zig` — 构建配置
- `board/esp32s3_devkit/build_config.zig` — DevKit build-time sdkconfig profile
- `board/esp32s3_devkit/bsp.zig` — DevKit runtime Wi-Fi board module
- `board/esp32s3_krovo2/build_config.zig` — Krovo2 build-time sdkconfig profile
- `board/esp32s3_krovo2/bsp.zig` — Krovo2 runtime Wi-Fi board module
