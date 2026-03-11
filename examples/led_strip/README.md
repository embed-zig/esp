# led_strip

## 简介

使用 `led_strip` 模块驱动板载 WS2812 RGB LED，循环显示 HSV 彩虹色。

## 功能

- 通过 RMT 后端初始化 LED strip
- HSV 色相循环，持续变换 LED 颜色

## 硬件

| 开发板 | LED GPIO | LED 数量 |
|--------|----------|----------|
| ESP32-S3 DevKit v1.0 | GPIO 48 | 1 |

## 构建与烧录

```bash
cd examples/led_strip
zig build flash-monitor -Dbuild_config=board/esp32s3_devkit/build_config.zig -Dbsp=board/esp32s3_devkit/bsp.zig -Dport=/dev/cu.usbmodem1301 -Desp_idf=$ESP_IDF -Dtimeout=15
```
当前示例已切换到拆分式 board 目录，因此需要同时传入 `-Dbuild_config` 与 `-Dbsp`。

## 源码结构

- `src/main.zig` — 应用逻辑
- `build.zig` — 构建配置
- `board/esp32s3_devkit/build_config.zig` — build-time sdkconfig profile
- `board/esp32s3_devkit/bsp.zig` — runtime board module（pin 定义）
