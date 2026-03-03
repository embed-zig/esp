# bt_vhci_smoke

## 简介

Bluetooth VHCI 冒烟测试。初始化 BT 控制器，注册 HCI 回调，发送 HCI Reset 命令。

## 功能

- NVS 初始化
- BT 控制器 init/enable（BLE 模式）
- VHCI 回调注册
- HCI Reset 命令发送

## 构建与烧录

```bash
cd examples/bt_vhci_smoke
zig build flash-monitor -Dboard=board/esp32s3_devkit.zig -Dport=/dev/cu.usbmodem1301 -Desp_idf=$ESP_IDF -Dtimeout=15
```

## 运行结果

**测试日期**: 2026-03-03 | **开发板**: ESP32-S3 DevKit

| 固件 | 大小 |
|------|------|
| bootloader | 21,008 bytes (0x5210) |
| partition-table | 3,072 bytes |
| bt_vhci_smoke.bin | 396,272 bytes (0x60BF0) |

| 内存 | 数值 |
|------|------|
| free heap | 352,364 |
| min free heap | 352,364 |

## 源码结构

- `src/main.zig` — 应用逻辑
- `build.zig` — 构建配置
- `board/*.zig` — 板级配置（esp32s3_devkit.zig, esp32s3_krovo2.zig, esp32s3_szp.zig）
