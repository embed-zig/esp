# esp_sr

## Overview

AEC + NS + AGC benchmark that runs on any ESP32-S3 board with PSRAM.
No audio hardware (I2S, codec) required — audio data is embedded in the firmware
binary via `@embedFile` and copied to PSRAM at runtime.

## What it tests

1. **Algorithm binary size**: Measures firmware binary size impact of linking AEC, NS, and AGC from `esp-sr`.
2. **Memory profiling**: Reports DRAM and PSRAM usage at each initialization stage (AEC, NS, AGC) and after processing.
3. **AEC correctness**: Two test cases:
   - **Test A**: `aec(far_end, far_end)` — input equals reference, expects near-zero output (echo cancellation).
   - **Test B**: `aec(near_end, far_end)` — 1 kHz sine as near-end, melody as far-end, expects sine preservation.
4. **NS + AGC pipeline**: Runs noise suppression and automatic gain control on AEC output.

## Hardware

- ESP32-S3 with PSRAM (DevKit N8R8 or SZP)
- No additional peripherals needed

## Audio Files

Synthetic 16 kHz 16-bit mono PCM, embedded via `@embedFile`:

| File | Content | Size |
|------|---------|------|
| `src/far_end.raw` | "Twinkle Twinkle Little Star" melody with harmonics | 96 KB |
| `src/near_end.raw` | Continuous 1 kHz sine wave | 96 KB |

Regenerate with: `python3 audio/gen_test_audio.py`

## Build & Flash

```bash
cd examples/esp_sr

# SZP board
zig build flash-monitor -Dboard=board/esp32s3_szp.zig -Dport=/dev/cu.usbmodem14301 -Desp_idf=$ESP_IDF -Dtimeout=15

# DevKit board
zig build flash-monitor -Dboard=board/esp32s3_devkit.zig -Dport=/dev/cu.usbmodem1301 -Desp_idf=$ESP_IDF -Dtimeout=15
```

## Test Results

**Test date**: 2026-03-05 | **Board**: ESP32-S3 SZP (16MB flash, 8MB PSRAM, 240MHz)

### Binary size

| Component | Size |
|-----------|------|
| bootloader | 21,008 bytes |
| partition-table | 3,072 bytes |
| esp_sr.bin | 536,368 bytes |

### Memory layout (idf_size)

| Section | Used | Total | Used % |
|---------|------|-------|--------|
| Flash Code (.text) | 210,270 | — | — |
| Flash Data (.rodata) | 246,656 | — | — |
| IRAM (.text + .vectors) | 16,383 | 16,384 | 99.99% |
| DRAM (.text + .data + .bss) | 65,095 | 341,760 | 19.05% |

### Runtime memory (PSRAM / DRAM)

| Stage | DRAM used | PSRAM used |
|-------|-----------|------------|
| Boot | — | — |
| Audio buffers (5 x 48000 samples) | 0 | 481,300 |
| AEC init | 0 | 96,844 |
| NS init | 0 | 33,796 |
| AGC init | 0 | 676 |
| **Total algorithm init** | **0** | **131,316** |
| **Total from boot** | **0** | **612,616** |

Boot free memory: PSRAM 8,386,148 / 8,388,608 bytes, DRAM 349,207 / 429,575 bytes.

### AEC test results

| Test | Input RMS | Output RMS | Metric |
|------|-----------|------------|--------|
| A: aec(far, far) | 8,858 | 1,128 | 88% suppression |
| B: aec(near, far) | 8,485 | 5,034 | 96% sine sign consistency |
| B after NS | — | 3,870 | — |
| B after AGC | — | 7,294 | — |

### Full output

```
========================================
  ESP-SR AEC/NS/AGC Benchmark
========================================

=== Memory: boot ===
  Total free:     8703324 bytes
  Internal free:  341703 bytes
  PSRAM:          8386148 / 8388608 bytes free
  Internal(caps): 349207 / 429575 bytes free

[1] Allocating audio buffers in PSRAM...
--- Memory delta: buffer allocation ---
  DRAM used:  0 bytes
  PSRAM used: 481300 bytes

[2] Loading audio data...
  'far_end': loaded 48000 samples from embedded data (@embedFile)
  'near_end': loaded 48000 samples from embedded data (@embedFile)
  far_end  RMS: 8858
  near_end RMS: 8485

[3] Initializing AEC...
--- Memory delta: AEC init ---
  DRAM used:  0 bytes
  PSRAM used: 96844 bytes
  AEC chunk size: 256 samples

[4] Initializing NS...
--- Memory delta: NS init ---
  DRAM used:  0 bytes
  PSRAM used: 33796 bytes

[5] Initializing AGC...
--- Memory delta: AGC init ---
  DRAM used:  0 bytes
  PSRAM used: 676 bytes

=== Memory: after all init ===
  Total free:     8090708 bytes
  Internal free:  341703 bytes
  PSRAM:          7773532 / 8388608 bytes free
  Internal(caps): 349207 / 429575 bytes free
--- Memory delta: total algorithm init ---
  DRAM used:  0 bytes
  PSRAM used: 131316 bytes

========================================
  Test A: aec(far_end, far_end)
  Input = ref => expect near-zero output
========================================
  Frames: 187 in 1140 ms
  Input  RMS:  8858  peak: 11042
  Output RMS:  1128  peak: 21846
  Suppression: 88%

========================================
  Test B: aec(near_end_sine, far_end_melody)
  Near=1kHz sine, Ref=melody => preserve sine
========================================
  Frames: 187 in 1174 ms
  near_end input  RMS: 8485  peak: 12000
  AEC output      RMS: 5034  peak: 21846
  Sine sign consistency (1-2s): 13466/14000 (96%)

[NS+AGC on Test B output]
  NS:  300 frames in 444 ms, RMS: 3870
  AGC: 300 frames in 20 ms, RMS: 7294

========================================
  Summary
========================================
  far_end (melody)     RMS: 8858
  near_end (1kHz sine) RMS: 8485
  Test A: aec(far,far) RMS: 1128  (expect ~0)
  Test B: aec(near,far)RMS: 5034  (expect ~near)
  Test B after NS      RMS: 3870
  Test B after AGC     RMS: 7294

=== Memory: final ===
  Total free:     8090708 bytes
  Internal free:  341703 bytes
  PSRAM:          7773532 / 8388608 bytes free
  Internal(caps): 349207 / 429575 bytes free
--- Memory delta: total from boot ---
  DRAM used:  0 bytes
  PSRAM used: 612616 bytes

========================================
  ESP-SR benchmark complete.
========================================
```

## Source structure

- `src/main.zig` — entry point
- `src/aec.zig` — AEC/NS/AGC benchmark logic, memory profiling
- `src/audio.zig` — audio data loading (`@embedFile`), RMS/peak computation
- `src/far_end.raw` — embedded far-end audio (melody)
- `src/near_end.raw` — embedded near-end audio (1 kHz sine)
- `audio/gen_test_audio.py` — Python script to regenerate .raw files
- `build.zig` — build configuration
- `board/esp32s3_devkit.zig` — DevKit board profile (8MB flash, PSRAM)
- `board/esp32s3_szp.zig` — SZP board profile (16MB flash, PSRAM)
