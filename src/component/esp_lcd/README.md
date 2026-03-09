# esp_lcd

Zig binding for the ESP-IDF `esp_lcd` component.

## ESP-IDF component

Maps to [`esp_lcd`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/peripherals/lcd.html).

## Module boundary

Provides type-safe Zig wrappers for SPI-connected LCD panels:

- `spi.Bus` — SPI bus initialization/deinitialization.
- `spi.PanelIo` — LCD panel IO over SPI (command/color/param transfer).
- `driver.st7789` / `driver.ili9341` — vendor panel driver creation.
- `Panel` — panel lifecycle and drawing operations (reset, init, drawBitmap, mirror, swap, invert, sleep).

C shim (`c_helper.c`) bridges Zig extern declarations to ESP-IDF C APIs that require
complex struct parameters. The shim is embedded in `root.zig` and auto-released to the
build directory by the scaffold generator.

## Dependencies

- ESP-IDF components: `esp_lcd`, `esp_driver_spi`, `driver`.
- No dependency on other espz modules.

## Zig toolchain requirement

This project targets Xtensa (ESP32-S3). The standard upstream Zig does not include
Xtensa backend support. You must use the Zig fork built from
[embed-zig/esp-zig-bootstrap](https://github.com/embed-zig/esp-zig-bootstrap),
which adds the Espressif Xtensa/RISC-V LLVM backend.

Install the bootstrap-built Zig binary and ensure it is on your `PATH` (or pass
`-Dzig_bin=<path>` to the build).

## Usage in firmware

```zig
const esp_lcd = @import("esp_lcd");
const board = @import("board_pins");

var bus = try esp_lcd.spi.Bus.init(.{
    .host_id = board.pins.lcd.spi_host,
    .sclk_io_num = board.pins.lcd.sclk,
    .mosi_io_num = board.pins.lcd.mosi,
    .max_transfer_bytes = 320 * 240 * 2,
    .dma_channel = 3,
});

var io = try esp_lcd.spi.PanelIo.init(&bus, .{
    .dc_io_num = board.pins.lcd.dc,
    .pclk_hz = board.pins.lcd.pclk_hz,
    .spi_mode = board.pins.lcd.spi_mode,
});

var panel = try esp_lcd.driver.create(esp_lcd.driver.st7789, &io, .{
    .reset_gpio_num = board.pins.lcd.rst,
});

try panel.reset();
try panel.init();
try panel.invertColor(true);
try panel.swapXY(true);
try panel.setDisplayEnabled(true);
try panel.drawBitmap(0, 0, 320, 1, @ptrCast(&line_buf));
```
