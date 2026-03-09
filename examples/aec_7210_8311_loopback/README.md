# aec_7210_8311_loopback

## Overview

AEC loopback test using ES7210 4-channel ADC and ES8311 DAC/codec. Captures microphone audio and DAC reference via full-duplex I2S, processes through the ESP-SR AEC pipeline, and plays back the result in real-time — forming a continuous loopback for interactive echo cancellation testing.

## Features

- ES7210 4-channel ADC (dual microphone via TDM)
- ES8311 DAC playback + ADC right channel as DAC reference for AEC
- I2S full-duplex (TDM RX + STD TX)
- AEC echo cancellation with real-time loopback
- Standalone ES7210/ES8311 drivers (no external codec library)

## Build & Flash

```bash
cd examples/aec_7210_8311_loopback
zig build flash-monitor -Dboard=board/esp32s3_szp.zig -Dport=/dev/cu.usbmodem14301 -Desp_idf=$ESP_IDF -Dtimeout=20
```

## Source Layout

- `src/main.zig` — application logic (loopback audio pipeline)
- `src/aec.zig` — AEC processing wrapper
- `src/board.zig` — board abstraction (I2C / I2S / codec init)
- `src/es7210.zig` — ES7210 4-channel ADC driver
- `src/es8311.zig` — ES8311 DAC/ADC codec driver
- `board/esp32s3_szp.zig` — SZP board pin definitions
- `board/esp32s3_korvo2_v3.zig` — Korvo2 v3 board pin definitions
