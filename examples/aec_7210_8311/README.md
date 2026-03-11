# aec_7210_8311

## Overview

AEC (Acoustic Echo Cancellation) demo using ES7210 4-channel ADC and ES8311 DAC/codec. Full-duplex I2S captures microphone audio and DAC reference simultaneously, then processes through the ESP-SR algorithm pipeline.

## Features

- ES7210 4-channel ADC (dual microphone via TDM)
- ES8311 DAC playback + ADC right channel as DAC reference for AEC
- I2S full-duplex (TDM RX + STD TX)
- AEC echo cancellation (independent processing per mic channel)
- MASE dual-mic beamforming / speech enhancement
- NS noise suppression
- AGC automatic gain control
- PCA9557 PA amplifier control

## Test Flow

1. Generate a "Twinkle Twinkle Little Star" melody (5 s, 16 kHz 16-bit PCM)
2. Play the melody through the speaker while recording via microphone, processed through AEC → MASE → NS → AGC pipeline
3. 1 s pause
4. Play back the processed recording
5. If AEC is working, the playback should be clean — no melody echo

## Build & Flash

This example uses the separated `build_config` + `bsp` layout, so both flags are required:

```bash
cd examples/aec_7210_8311
zig build flash-monitor -Dbuild_config=board/esp32s3_szp/build_config.zig -Dbsp=board/esp32s3_szp/bsp.zig -Dport=/dev/cu.usbmodem14301 -Desp_idf="$ESP_IDF" -Dtimeout=20
```

Switch board profile explicitly when needed:

```bash
zig build flash-monitor -Dbuild_config=board/esp32s3_krovo2_v3/build_config.zig -Dbsp=board/esp32s3_krovo2_v3/bsp.zig -Dport=/dev/cu.usbmodem14301 -Desp_idf="$ESP_IDF" -Dtimeout=20
```

## Results

**Date**: TODO | **Board**: ESP32-S3 SZP

| Firmware | Size |
|----------|------|
| bootloader | TODO |
| partition-table | TODO |
| aec_7210_8311.bin | TODO |

| Memory | Value |
|--------|-------|
| free heap (init) | TODO |
| free heap (after alloc) | TODO |
| min free heap | TODO |

## Source Layout

- `src/main.zig` — application logic (audio pipeline + test sequence)
- `src/es7210.zig` — ES7210 4-channel ADC driver
- `src/es8311.zig` — ES8311 DAC/ADC codec driver
- `build.zig` — build configuration
- `board/esp32s3_szp/build_config.zig` — SZP sdkconfig profile
- `board/esp32s3_szp/bsp.zig` — SZP pin definitions and audio BSP
- `board/esp32s3_krovo2_v3/build_config.zig` — Krovo2 v3 sdkconfig profile
- `board/esp32s3_krovo2_v3/bsp.zig` — Krovo2 v3 pin definitions and audio BSP
