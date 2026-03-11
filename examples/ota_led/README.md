# OTA LED Demo

Demonstrates OTA firmware update from a custom data partition (`fw_store`).

Two firmware variants (red LED and green LED) are compiled from the same source with
different `-Dcolor` options. Both binaries are packed into the `fw_store` partition.
Pressing the BOOT button reads the alternate firmware from `fw_store`, writes it to
the next OTA slot, and reboots.

## Partition layout

| Name     | Type | SubType | Offset     | Size      |
|----------|------|---------|------------|-----------|
| nvs      | data | nvs     | 0x9000     | 0x4000    |
| otadata  | data | ota     | 0xd000     | 0x2000    |
| phy_init | data | phy     | 0xf000     | 0x1000    |
| ota_0    | app  | ota_0   | 0x10000    | 0x180000  |
| ota_1    | app  | ota_1   | 0x190000   | 0x180000  |
| fw_store | data | 0x40    | 0x310000   | 0xE0000   |

## Build and flash

```bash
cd examples/ota_led

# Build red firmware
zig build build -Dbuild_config=board/esp32s3_devkit/build_config.zig -Dbsp=board/esp32s3_devkit/bsp.zig -Dcolor=red -Desp_idf=/path/to/esp-idf
cp build/idf/build/ota_led.bin firmware/red.bin

# Build green firmware
zig build build -Dbuild_config=board/esp32s3_devkit/build_config.zig -Dbsp=board/esp32s3_devkit/bsp.zig -Dcolor=green -Desp_idf=/path/to/esp-idf
cp build/idf/build/ota_led.bin firmware/green.bin

# Flash red as initial firmware + fw_store with both bins
zig build flash -Dbuild_config=board/esp32s3_devkit/build_config.zig -Dbsp=board/esp32s3_devkit/bsp.zig -Dcolor=red -Dport=/dev/cu.usbmodem1301 -Desp_idf=/path/to/esp-idf

# Monitor
zig build monitor -Dbuild_config=board/esp32s3_devkit/build_config.zig -Dbsp=board/esp32s3_devkit/bsp.zig -Dport=/dev/cu.usbmodem1301 -Desp_idf=/path/to/esp-idf
```
当前示例已切换到拆分式 board 目录，因此需要同时传入 `-Dbuild_config` 与 `-Dbsp`；板级配置与 `-Dcolor` 应用选项可以同时传入。

## Expected behavior

1. After flash: LED is RED, serial shows OTA state confirmed
2. Press BOOT: reads `green.bin` from `fw_store`, OTA writes, restarts
3. After restart: LED is GREEN
4. Press BOOT again: reads `red.bin`, OTA writes, restarts -> LED RED
5. Cycle repeats
