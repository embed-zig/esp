const std = @import("std");
const esp = @import("esp");
const rom = esp.component.esp_rom;
const freertos = esp.component.freertos;
const led = esp.component.led_strip;
const gpio = esp.component.esp_driver_gpio;
const app_meta = esp.component.app_metadata;
const ota = app_meta.ota;
const spiffs = esp.component.spiffs.spiffs;
const posix = esp.component.newlib.fs;
const board = @import("board");

const color: []const u8 = board.config.app.color;
const is_red = std.mem.eql(u8, color, "red");
const is_green = std.mem.eql(u8, color, "green");

comptime {
    if (!is_red and !is_green) @compileError("color must be 'red' or 'green'");
}

const other_bin: [:0]const u8 = if (is_red) "/fw_store/green.bin" else "/fw_store/red.bin";

const strip_pins = board.pins.led_strip;
const boot_pin = board.pins.boot_button.gpio;

extern fn espz_system_restart() noreturn;

export fn zig_esp_main() callconv(.c) void {
    _ = rom.esp_rom_printf("[ota_led] booting as %s\n", color.ptr);

    ota.markValid() catch {
        _ = rom.esp_rom_printf("[ota_led] WARN: markValid failed (first boot is normal)\n");
    };

    spiffs.mount("fw_store", "/fw_store", 5, false) catch {
        _ = rom.esp_rom_printf("[ota_led] SPIFFS mount failed\n");
        return;
    };
    _ = rom.esp_rom_printf("[ota_led] SPIFFS mounted at /fw_store\n");

    if (posix.openDirectory("/fw_store")) |dir| {
        _ = rom.esp_rom_printf("[ota_led] listing /fw_store:\n");
        while (posix.readDirectory(dir)) |ent| {
            _ = rom.esp_rom_printf("[ota_led]   file: %s (type=%d)\n", @as([*:0]const u8, @ptrCast(&ent.name)), @as(i32, ent.d_type));
        }
        posix.closeDirectory(dir);
    } else |_| {
        _ = rom.esp_rom_printf("[ota_led] opendir /fw_store failed\n");
    }

    const strip = led.LedStrip.initRmt(.{
        .gpio_num = strip_pins.gpio,
        .max_leds = strip_pins.max_leds,
    }, .{}) catch {
        _ = rom.esp_rom_printf("[ota_led] LED strip init failed\n");
        return;
    };

    strip.clear() catch {};
    if (is_red) {
        strip.setPixel(0, 60, 0, 0) catch {};
    } else {
        strip.setPixel(0, 0, 60, 0) catch {};
    }
    strip.refresh() catch {};

    _ = rom.esp_rom_printf("[ota_led] LED set to %s, waiting for BOOT button press...\n", color.ptr);

    gpio.setDirection(boot_pin, .input) catch {
        _ = rom.esp_rom_printf("[ota_led] GPIO init failed\n");
        return;
    };
    gpio.setPullMode(boot_pin, .pullup_only) catch {};

    while (true) {
        if (gpio.getLevel(boot_pin) == 0) {
            freertos.delay(50);
            if (gpio.getLevel(boot_pin) == 0) {
                _ = rom.esp_rom_printf("[ota_led] BOOT pressed, starting OTA...\n");
                doOta(strip) catch |err| {
                    _ = rom.esp_rom_printf("[ota_led] OTA failed: %d\n", @as(i32, @intFromError(err)));
                    strip.clear() catch {};
                    if (is_red) {
                        strip.setPixel(0, 60, 0, 0) catch {};
                    } else {
                        strip.setPixel(0, 0, 60, 0) catch {};
                    }
                    strip.refresh() catch {};
                };
            }
        }
        freertos.delay(100);
    }
}

fn setYellow(strip: led.LedStrip) void {
    strip.setPixel(0, 60, 40, 0) catch {};
    strip.refresh() catch {};
}

fn doOta(strip: led.LedStrip) !void {
    setYellow(strip);

    _ = rom.esp_rom_printf("[ota_led] opening %s...\n", other_bin.ptr);

    const fd = posix.openFile(other_bin.ptr, posix.O_RDONLY) catch {
        _ = rom.esp_rom_printf("[ota_led] file open failed\n");
        return error.FileNotFound;
    };
    defer posix.closeFile(fd);

    const file_size = posix.fileSize(fd) catch {
        _ = rom.esp_rom_printf("[ota_led] file stat failed\n");
        return error.FileNotFound;
    };
    _ = rom.esp_rom_printf("[ota_led] file size: %u bytes\n", file_size);

    const target_part = ota.getNextUpdatePartition() catch {
        _ = rom.esp_rom_printf("[ota_led] no OTA target partition\n");
        return error.NoPartition;
    };

    const handle = ota.begin(target_part, file_size) catch {
        _ = rom.esp_rom_printf("[ota_led] ota begin failed\n");
        return error.BeginFailed;
    };

    var buf: [1024]u8 = undefined;
    var written: u32 = 0;

    while (true) {
        const n = posix.readFile(fd, &buf) catch {
            _ = rom.esp_rom_printf("[ota_led] file read failed\n");
            ota.abort(handle);
            return error.ReadFailed;
        };
        if (n == 0) break;

        ota.write(handle, buf[0..n]) catch {
            _ = rom.esp_rom_printf("[ota_led] ota write failed\n");
            ota.abort(handle);
            return error.WriteFailed;
        };

        written += @intCast(n);
        if (written % (64 * 1024) == 0 or n < buf.len) {
            _ = rom.esp_rom_printf("[ota_led] written %u / %u bytes\n", written, file_size);
        }
    }

    ota.end(handle) catch {
        _ = rom.esp_rom_printf("[ota_led] ota end failed\n");
        return error.EndFailed;
    };

    ota.setBootPartition(target_part) catch {
        _ = rom.esp_rom_printf("[ota_led] set boot partition failed\n");
        return error.SetBootFailed;
    };

    _ = rom.esp_rom_printf("[ota_led] OTA complete, blinking and restarting...\n");

    for (0..6) |i| {
        if (i % 2 == 0) {
            strip.clear() catch {};
        } else {
            setYellow(strip);
        }
        strip.refresh() catch {};
        freertos.delay(200);
    }

    espz_system_restart();
}

const OtaError = error{
    FileNotFound,
    NoPartition,
    BeginFailed,
    WriteFailed,
    ReadFailed,
    EndFailed,
    SetBootFailed,
};
