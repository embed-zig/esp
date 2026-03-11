# link_attr

## Overview

Demonstrates Zig link-time attributes and memory layout control on ESP32-S3,
with side-by-side C `__attribute__` equivalents.

## Features

- `linksection` — place functions/data in specific memory regions (IRAM, DRAM, Flash .rodata, .noinit)
- `align` — control variable alignment (DMA 32-byte, page 4KB)
- `packed struct` — no-padding compact layout (protocol parsing, register maps)
- `export` — prevent linker from stripping symbols, callable from C
- `callconv(.c)` — C calling convention, prevents inlining
- `@embedFile` — Zig builtin that embeds binary files as const (linker places in .rodata)
- Combined usage — IRAM function + DRAM aligned data (ISR + DMA patterns)

## Zig vs C Attribute Reference

| Zig | C equivalent | Purpose |
|-----|-------------|---------|
| `linksection(".iram1")` | `IRAM_ATTR` | Place function in IRAM (required for ISRs) |
| `linksection(".dram0.data")` | `DRAM_ATTR` | Place data in internal DRAM |
| `linksection(".rodata")` | default `const` | Read-only data in flash |
| `linksection(".noinit")` | `__NOINIT_ATTR` | Survives soft reset, not zeroed on boot |
| `@embedFile(...)` | `xxd -i` + `const uint8_t[]` | Zig builtin; embeds file as const (linker places in .rodata) |
| `align(N)` | `__attribute__((aligned(N)))` | Memory alignment |
| `packed struct` | `__attribute__((packed))` | Compact layout |
| `export fn` | `__attribute__((used))` | Preserve symbol in binary |
| `callconv(.c)` | `extern "C"` | C calling convention |

## ESP32-S3 Memory Address Ranges

| Region | Address range | Description |
|--------|--------------|-------------|
| IRAM | `0x40370000` – `0x4037FFFF` | Instruction RAM, code only |
| DRAM | `0x3FC80000` – `0x3FCFFFFF` | Data RAM, mutable data |
| Flash (mmap) | `0x3C000000` – `0x3DFFFFFF` | Read-only data, XIP access |

## Build & Flash

```bash
cd examples/link_attr
zig build flash-monitor -Dbuild_config=board/esp32s3_devkit/build_config.zig -Dbsp=board/esp32s3_devkit/bsp.zig -Dport=/dev/cu.usbmodem1301 -Desp_idf=$ESP_IDF -Dtimeout=15
```
当前示例已切换到拆分式 board 目录，因此需要同时传入 `-Dbuild_config` 与 `-Dbsp`。

## Test Results

**Test date**: 2026-03-05 | **Board**: ESP32-S3 DevKit

### Binary size

| Component | Size |
|-----------|------|
| bootloader | 21,008 bytes |
| partition-table | 3,072 bytes |
| link_attr.bin | 209,200 bytes |

### Memory layout (idf_size)

| Section | Used | Total | Used % |
|---------|------|-------|--------|
| Flash Code (.text) | 96,914 | — | — |
| Flash Data (.rodata) | 43,388 | — | — |
| IRAM (.text + .vectors) | 16,383 | 16,384 | 99.99% |
| DRAM (.text + .data + .bss + .noinit) | 64,859 | 341,760 | 18.98% |

### Runtime output

```
========================================
  Zig Link Attributes Demo (ESP32-S3)
========================================

[linksection]
  iram_fast_function @ 0x40376d3c (expect 0x4037xxxx IRAM range)
  iram_counter       @ 0x3fc94c20 = 1
  dram_lookup        @ 0x3fc94c24 = [0xDEAD, 0xBEEF, 0xCAFE, 0xF00D]
  rodata_magic       @ 0x3c028bb8 = 0x5A5A5A5A (expect flash 0x3Cxxxxxx)
  noinit_boot_count  @ 0x3fc94c60 = 1 (increments across soft resets)
  embedded_data      @ 0x3c028bbc, 32 bytes (flash .rodata via @embedFile)

[align]
  dma_buffer  @ 0x3fc96000  align=32   aligned: YES
  page_buffer @ 0x3fc97000  align=4096 aligned: YES

[packed]
  PacketHeader size: 8 bytes (expect 8, not 12)
  PacketHeader bytes: AB 00 04 03 2A 00 00 00
  RegBits size: 1 bytes (expect 1)
  RegBits value: 0x0B (enable=1, mode=5 => 0b_0000_1011 = 0x0B)

[export]
  zig_exported_callback @ 0x420092f8
  called from C or linker script

[noinline]
  noinline_helper(100) = 3107

[combined: IRAM + export]
  iram_isr_handler   @ 0x40376d4c
  iram_counter after 3 calls: 4
  dma_descriptor     @ 0x3fc94c40  align=16 + .dram0.data

[memory]
  heap free: 378844 bytes

========================================
  All attribute demos complete.
========================================
```

## Caveats

- **Do not place mutable data in `.iram1`**: ESP32 IRAM is instruction memory. Writing mutable data there triggers `Cache disabled but cached memory region accessed` panic. Use `.dram0.data` for mutable data accessed from ISRs.
- **`.noinit` variables have undefined initial values**: Random on first power-up; only preserved across soft resets (`esp_restart`).
- **`@embedFile` data lives in the app partition**: Embedded data is part of the app binary and cannot be placed in a separate data partition. Use `esp_partition_read` for data that needs its own partition.

## Source structure

- `src/main.zig` — all attribute demos and runtime verification
- `src/demo_blob.bin` — small binary file for `@embedFile` demo
- `build.zig` — build configuration
- `board/esp32s3_devkit/build_config.zig` — build-time sdkconfig profile
- `board/esp32s3_devkit/bsp.zig` — runtime board module
