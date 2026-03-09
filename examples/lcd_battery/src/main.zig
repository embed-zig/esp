const std = @import("std");
const esp = @import("esp");
const esp_component = esp.component;
const hal = esp.hal;
const Color565 = hal.display.Color565;
const board = @import("board");
const rom = esp_component.esp_rom;
const newlib = esp_component.newlib;
const freertos = esp_component.freertos;
const heap = esp_component.heap;

extern fn abort() noreturn;

pub const std_options: std.Options = .{
    .logFn = struct {
        fn log(
            comptime _: std.log.Level,
            comptime _: @TypeOf(.enum_literal),
            comptime _: []const u8,
            _: anytype,
        ) void {}
    }.log,
};

pub fn panic(msg: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    _ = rom.esp_rom_printf("\n*** ZIG PANIC ***\n");
    for (msg) |ch| {
        _ = rom.esp_rom_printf("%c", @as(i32, ch));
    }
    _ = rom.esp_rom_printf("\n*****************\n");
    abort();
}

const b = board.pins;

const LCD_W: usize = b.lcd.h_res;
const LCD_H: usize = b.lcd.v_res;
const FB_PIXELS = LCD_W * LCD_H;

const MALLOC_CAP_DMA: u32 = 4;

const COLOR_BLACK: Color565 = 0x0000;
const COLOR_WHITE: Color565 = 0xFFFF;
const COLOR_GREEN: Color565 = 0x07E0;
const COLOR_ORANGE: Color565 = 0xFD20;
const COLOR_RED: Color565 = 0xF800;

const esp_rom_printf = rom.esp_rom_printf;

var g_i2c: hal.I2c.DriverType = undefined;
var g_expander_dev: hal.I2c.DriverType.DeviceHandle = undefined;

fn pca9557_write_byte(reg: u8, data: u8) void {
    g_i2c.write(g_expander_dev, &.{ reg, data }) catch {
        _ = esp_rom_printf("FATAL: I2C write failed\n");
        newlib.abort();
    };
}

fn pca9557_set_output(bit: u8, level: bool) void {
    var read_buf: [1]u8 = undefined;
    g_i2c.writeRead(g_expander_dev, &.{b.lcd_cs_expander.output_port_reg}, &read_buf) catch {
        _ = esp_rom_printf("FATAL: I2C write_read failed\n");
        newlib.abort();
    };
    var output = read_buf[0];
    if (level) {
        output |= bit;
    } else {
        output &= ~bit;
    }
    pca9557_write_byte(b.lcd_cs_expander.output_port_reg, output);
}

// ── framebuffer drawing (all ops write to fb[], flushed via flush) ──

var fb: [*]Color565 = undefined;

fn fbFillRect(x: i32, y: i32, w: i32, h: i32, color: Color565) void {
    if (w <= 0 or h <= 0) return;
    const x0: usize = if (x < 0) 0 else @intCast(x);
    const y0: usize = if (y < 0) 0 else @intCast(y);
    const x1: usize = @min(@as(usize, @intCast(@max(x + w, 0))), LCD_W);
    const y1: usize = @min(@as(usize, @intCast(@max(y + h, 0))), LCD_H);
    for (y0..y1) |row| {
        for (x0..x1) |col| {
            fb[row * LCD_W + col] = color;
        }
    }
}

fn flush(drv: *hal.Display.DriverType) void {
    const data: []const Color565 = fb[0..FB_PIXELS];
    drv.drawBitmap(0, 0, @intCast(LCD_W), @intCast(LCD_H), data) catch {};
}

// ── font ──

const DIGIT_FONT = [12][7]u8{
    .{ 0x0E, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0E }, // 0
    .{ 0x04, 0x0C, 0x04, 0x04, 0x04, 0x04, 0x0E }, // 1
    .{ 0x0E, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1F }, // 2
    .{ 0x1E, 0x01, 0x01, 0x0E, 0x01, 0x01, 0x1E }, // 3
    .{ 0x02, 0x06, 0x0A, 0x12, 0x1F, 0x02, 0x02 }, // 4
    .{ 0x1F, 0x10, 0x1E, 0x01, 0x01, 0x11, 0x0E }, // 5
    .{ 0x06, 0x08, 0x10, 0x1E, 0x11, 0x11, 0x0E }, // 6
    .{ 0x1F, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08 }, // 7
    .{ 0x0E, 0x11, 0x11, 0x0E, 0x11, 0x11, 0x0E }, // 8
    .{ 0x0E, 0x11, 0x11, 0x0F, 0x01, 0x02, 0x0C }, // 9
    .{ 0x18, 0x19, 0x02, 0x04, 0x08, 0x13, 0x03 }, // %
    .{ 0x00, 0x04, 0x04, 0x00, 0x04, 0x04, 0x00 }, // :
};

fn fbDrawGlyph(x: i32, y: i32, ch: u8, fg: Color565, bg: Color565, scale: i32) void {
    const glyph: ?*const [7]u8 = if (ch >= '0' and ch <= '9')
        &DIGIT_FONT[ch - '0']
    else if (ch == '%')
        &DIGIT_FONT[10]
    else if (ch == ':')
        &DIGIT_FONT[11]
    else
        null;
    const g = glyph orelse return;

    var row: i32 = 0;
    while (row < 7) : (row += 1) {
        var col: i32 = 0;
        while (col < 5) : (col += 1) {
            const shift: u3 = @intCast(4 - col);
            const on = (g[@intCast(row)] & (@as(u8, 1) << shift)) != 0;
            fbFillRect(x + col * scale, y + row * scale, scale, scale, if (on) fg else bg);
        }
    }
}

fn fbDrawText(x: i32, y: i32, text: []const u8, fg: Color565, bg: Color565, scale: i32) void {
    var cursor = x;
    for (text) |ch| {
        fbDrawGlyph(cursor, y, ch, fg, bg, scale);
        cursor += 6 * scale;
    }
}

// ── battery logic ──

fn batteryPercent(mv: u32) u8 {
    if (b.battery_adc.full_mv <= b.battery_adc.empty_mv) return 0;
    if (mv <= b.battery_adc.empty_mv) return 0;
    if (mv >= b.battery_adc.full_mv) return 100;
    const result = (mv - b.battery_adc.empty_mv) * 100 / (b.battery_adc.full_mv - b.battery_adc.empty_mv);
    return if (result > 100) 100 else @intCast(result);
}

fn batteryColor(percent: u8) Color565 {
    if (percent >= 60) return COLOR_GREEN;
    if (percent >= 25) return COLOR_ORANGE;
    return COLOR_RED;
}

fn formatPercent(buf: *[8]u8, percent: u8) []const u8 {
    if (percent >= 100) {
        buf[0] = '1';
        buf[1] = '0';
        buf[2] = '0';
        buf[3] = '%';
        return buf[0..4];
    }
    if (percent >= 10) {
        buf[0] = '0' + percent / 10;
        buf[1] = '0' + percent % 10;
        buf[2] = '%';
        return buf[0..3];
    }
    buf[0] = '0' + percent;
    buf[1] = '%';
    return buf[0..2];
}

const BAT_BODY_X: i32 = 44;
const BAT_BODY_Y: i32 = 70;
const BAT_BODY_W: i32 = 232;
const BAT_BODY_H: i32 = 100;
const BAT_BORDER: i32 = 4;
const BAT_INNER_X = BAT_BODY_X + BAT_BORDER;
const BAT_INNER_Y = BAT_BODY_Y + BAT_BORDER;
const BAT_INNER_W = BAT_BODY_W - BAT_BORDER * 2;
const BAT_INNER_H = BAT_BODY_H - BAT_BORDER * 2;
const BAT_FILL_PAD: i32 = 4;
const BAT_FILL_PAD_V: i32 = 6;
const BAT_MAX_FILL = BAT_INNER_W - BAT_FILL_PAD * 2;

const TEXT_X: i32 = 104;
const TEXT_Y: i32 = 188;
const TEXT_SCALE: i32 = 4;
const TEXT_MAX_CHARS: i32 = 4;
const TEXT_CLEAR_W = TEXT_MAX_CHARS * 6 * TEXT_SCALE;
const TEXT_CLEAR_H = 7 * TEXT_SCALE;

fn drawBatteryShell() void {
    fbFillRect(0, 0, @intCast(LCD_W), @intCast(LCD_H), COLOR_BLACK);
    fbFillRect(BAT_BODY_X, BAT_BODY_Y, BAT_BODY_W, BAT_BODY_H, COLOR_WHITE);
    fbFillRect(BAT_BODY_X + BAT_BODY_W, BAT_BODY_Y + 32, 14, 36, COLOR_WHITE);
    fbFillRect(BAT_INNER_X, BAT_INNER_Y, BAT_INNER_W, BAT_INNER_H, COLOR_BLACK);
}

fn drawBatteryFill(percent: u8) void {
    const fill_x = BAT_INNER_X + BAT_FILL_PAD;
    const fill_y = BAT_INNER_Y + BAT_FILL_PAD_V;
    const fill_h = BAT_INNER_H - BAT_FILL_PAD_V * 2;
    const fill_w = @divTrunc(BAT_MAX_FILL * @as(i32, percent), 100);

    fbFillRect(fill_x, fill_y, BAT_MAX_FILL, fill_h, COLOR_BLACK);
    if (fill_w > 0) {
        fbFillRect(fill_x, fill_y, fill_w, fill_h, batteryColor(percent));
    }

    fbFillRect(TEXT_X, TEXT_Y, TEXT_CLEAR_W, TEXT_CLEAR_H, COLOR_BLACK);
    var text_buf: [8]u8 = undefined;
    const text = formatPercent(&text_buf, percent);
    fbDrawText(TEXT_X, TEXT_Y, text, COLOR_WHITE, COLOR_BLACK, TEXT_SCALE);
}

// ── uptime ──

const UPTIME_SCALE: i32 = 2;
const UPTIME_CHARS: i32 = 5;
const UPTIME_CHAR_W = 6 * UPTIME_SCALE;
const UPTIME_W = UPTIME_CHARS * UPTIME_CHAR_W;
const UPTIME_H = 7 * UPTIME_SCALE;
const UPTIME_X: i32 = @as(i32, @intCast(LCD_W)) - UPTIME_W - 4;
const UPTIME_Y: i32 = 4;

fn formatUptime(buf: *[5]u8, seconds: u32) void {
    const mm = (seconds / 60) % 100;
    const ss = seconds % 60;
    buf[0] = '0' + @as(u8, @intCast(mm / 10));
    buf[1] = '0' + @as(u8, @intCast(mm % 10));
    buf[2] = ':';
    buf[3] = '0' + @as(u8, @intCast(ss / 10));
    buf[4] = '0' + @as(u8, @intCast(ss % 10));
}

fn fbDrawUptime(seconds: u32) void {
    var buf: [5]u8 = undefined;
    formatUptime(&buf, seconds);
    fbFillRect(UPTIME_X, UPTIME_Y, UPTIME_W, UPTIME_H, COLOR_BLACK);
    fbDrawText(UPTIME_X, UPTIME_Y, &buf, COLOR_WHITE, COLOR_BLACK, UPTIME_SCALE);
}

// ── entry ──

var g_display: hal.Display.DriverType = undefined;
var g_pwm: hal.Pwm.DriverType = undefined;
var g_adc: hal.Adc.DriverType = undefined;

export fn zig_esp_main() callconv(.c) void {
    _ = esp_rom_printf("lcd_battery: starting\n");

    const fb_bytes = FB_PIXELS * @sizeOf(Color565);
    const fb_ptr = heap.capsMalloc(fb_bytes, MALLOC_CAP_DMA) orelse {
        _ = esp_rom_printf("FATAL: framebuffer alloc failed (%u bytes)\n", @as(c_uint, fb_bytes));
        newlib.abort();
    };
    fb = @ptrCast(@alignCast(fb_ptr));
    _ = esp_rom_printf("lcd_battery: framebuffer allocated (%u bytes)\n", @as(c_uint, fb_bytes));

    g_i2c = hal.I2c.DriverType.initMaster(.{
        .port = @intCast(b.i2c.port),
        .sda = @intCast(b.i2c.sda),
        .scl = @intCast(b.i2c.scl),
        .freq_hz = b.i2c.freq_hz,
    }) catch {
        _ = esp_rom_printf("FATAL: I2C init failed\n");
        newlib.abort();
    };
    g_expander_dev = g_i2c.registerDevice(.{ .address = b.lcd_cs_expander.i2c_addr }) catch {
        _ = esp_rom_printf("FATAL: I2C register expander device failed\n");
        newlib.abort();
    };
    pca9557_write_byte(b.lcd_cs_expander.output_port_reg, b.lcd_cs_expander.init_output);
    pca9557_write_byte(b.lcd_cs_expander.config_port_reg, b.lcd_cs_expander.init_config);

    g_pwm = hal.Pwm.DriverType.init() catch {
        _ = esp_rom_printf("FATAL: PWM init failed\n");
        newlib.abort();
    };
    g_pwm.initChannelEx(0, b.lcd.backlight, 5000, true) catch {
        _ = esp_rom_printf("FATAL: PWM channel init failed\n");
        newlib.abort();
    };

    g_display = hal.Display.DriverType.init(.{
        .panel = .st7789,
        .width = b.lcd.h_res,
        .height = b.lcd.v_res,
        .host_id = b.lcd.spi_host,
        .sclk = b.lcd.sclk,
        .mosi = b.lcd.mosi,
        .cs = b.lcd.cs,
        .dc = b.lcd.dc,
        .reset = b.lcd.rst,
        .pclk_hz = b.lcd.pclk_hz,
        .spi_mode = b.lcd.spi_mode,
        .max_transfer_bytes = @intCast(@as(usize, b.lcd.h_res) * b.lcd.v_res * 2),
        .invert_color = b.lcd.invert_color,
        .swap_xy = b.lcd.swap_xy,
        .mirror_x = b.lcd.mirror_x,
        .mirror_y = b.lcd.mirror_y,
        .pre_init_hook = struct {
            fn hook() void {
                pca9557_set_output(b.lcd_cs_expander.cs_bit, false);
            }
        }.hook,
    }) catch {
        _ = esp_rom_printf("FATAL: Display init failed\n");
        newlib.abort();
    };

    g_pwm.setDuty(0, 65535) catch |err| {
        _ = esp_rom_printf("WARN: PWM set duty failed: %d\n", @intFromError(err));
    };

    g_adc = hal.Adc.DriverType.initConfig(b.battery_adc.unit, .{}) catch {
        _ = esp_rom_printf("FATAL: ADC init failed\n");
        newlib.abort();
    };

    _ = esp_rom_printf("lcd_battery: init complete\n");
    _ = esp_rom_printf("heap: free=%u min_free=%u\n", heap.freeHeapSize(), heap.minimumFreeHeapSize());

    drawBatteryShell();
    flush(&g_display);

    var prev_percent: u8 = 0xFF;
    var uptime: u32 = 0;

    while (true) {
        var battery_mv: u32 = b.battery_adc.empty_mv;

        if (g_adc.read(@intCast(b.battery_adc.channel))) |raw| {
            const sensed_mv: u32 = @as(u32, raw) * 3300 / 4095;
            battery_mv = sensed_mv * b.battery_adc.divider_num / b.battery_adc.divider_den;
        } else |_| {}

        const percent = batteryPercent(battery_mv);

        if (percent != prev_percent) {
            drawBatteryFill(percent);
            prev_percent = percent;
        }

        fbDrawUptime(uptime);
        uptime += 1;

        flush(&g_display);

        _ = esp_rom_printf("lcd_battery: percent=%u mv=%u uptime=%u\n", @as(c_uint, percent), @as(c_uint, battery_mv), uptime);
        freertos.delay(freertos.msToTicks(1000, board.config.freertos.tick_hz));
    }
}
