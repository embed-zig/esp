const rom = @import("esp_rom");
const freertos = @import("freertos");
const led = @import("led_strip");
const board = @import("board");

const strip_pins = board.pins.led_strip;

export fn zig_esp_main() callconv(.c) void {
    _ = rom.esp_rom_printf("led_strip: initializing on GPIO %d, %u LEDs\n", strip_pins.gpio, strip_pins.max_leds);

    const strip = led.LedStrip.initRmt(.{
        .gpio_num = strip_pins.gpio,
        .max_leds = strip_pins.max_leds,
    }, .{}) catch {
        _ = rom.esp_rom_printf("led_strip: init failed\n");
        return;
    };

    _ = rom.esp_rom_printf("led_strip: init ok, starting color cycle\n");

    strip.clear() catch {};

    var hue: u16 = 0;
    while (true) {
        strip.setPixelHsv(0, hue, 255, 25) catch {};
        strip.refresh() catch {};

        hue += 5;
        if (hue >= 360) hue = 0;

        freertos.delay(50);
    }
}
