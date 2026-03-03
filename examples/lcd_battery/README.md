# lcd_battery

## 简介

SZP 开发板 LCD 电池电量显示示例。使用 esp_lcd 模块驱动 ST7789 屏幕，ADC 读取电池电压，纯 Zig 绘图。

## 功能

- SPI LCD ST7789 驱动
- I2C PCA9557 IO 扩展
- LEDC 背光控制
- ADC 电池电压采集
- 纯 Zig 绘图（fill_rect, draw_text）

## 构建与烧录

```bash
cd examples/lcd_battery
zig build flash-monitor -Dboard=board/esp32s3_szp.zig -Dport=/dev/cu.usbmodem14301 -Desp_idf=$ESP_IDF -Dtimeout=15
```

## 运行结果

**测试日期**: 2026-03-03 | **开发板**: ESP32-S3 SZP

| 固件 | 大小 |
|------|------|
| bootloader | 21,008 bytes (0x5210) |
| partition-table | 3,072 bytes |
| lcd_battery.bin | 308,272 bytes (0x4B430) |

| 内存 | 数值 |
|------|------|
| free heap | 371,324 |
| min free heap | 371,324 |

## 源码结构

- `src/main.zig` — 应用逻辑
- `build.zig` — 构建配置
- `board/*.zig` — 板级配置（esp32s3_szp.zig）
