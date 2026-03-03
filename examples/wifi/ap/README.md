# wifi_ap

## 简介

Wi-Fi SoftAP 示例。开启指定 SSID 的热点，等待 STA 连接。

## 功能

- SoftAP 模式
- WPA2-PSK 认证
- board 文件配置 SSID/密码/信道

## 构建与烧录

```bash
cd examples/wifi/ap
zig build flash-monitor -Dboard=board/esp32s3_devkit.zig -Dport=/dev/cu.usbmodem1301 -Desp_idf=$ESP_IDF -Dtimeout=15
```

## 运行结果

**测试日期**: 2026-03-03 | **开发板**: ESP32-S3 DevKit

| 固件 | 大小 |
|------|------|
| bootloader | 21,008 bytes (0x5210) |
| partition-table | 3,072 bytes |
| wifi_ap.bin | 742,352 bytes (0xB55D0) |

| 内存 | 数值 |
|------|------|
| free heap | 333,916 |
| min free heap | 333,916 |

## 源码结构

- `src/main.zig` — 应用逻辑
- `build.zig` — 构建配置
- `board/*.zig` — 板级配置（esp32s3_devkit.zig, esp32s3_krovo2.zig）
