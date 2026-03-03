const board = @import("board_pins");
const esp_lcd = @import("esp_lcd");
const rom = @import("esp_rom");
const newlib = @import("newlib");
const freertos = @import("freertos");
const heap = @import("heap");
const i2c = @import("esp_driver_i2c");
const ledc = @import("esp_driver_ledc");
const adc = @import("esp_adc");

const b = board.pins;

const SPI_DMA_CH_AUTO: i32 = 3;

const COLOR_BLACK: u16 = 0x0000;
const COLOR_WHITE: u16 = 0xFFFF;
const COLOR_GREEN: u16 = 0x07E0;
const COLOR_ORANGE: u16 = 0xFD20;
const COLOR_RED: u16 = 0xF800;

const esp_rom_printf = rom.esp_rom_printf;

fn lcdCheck(result: esp_lcd.Error!void) void {
    result catch {
        _ = esp_rom_printf("FATAL LCD error\n");
        newlib.abort();
    };
}

// ── I2C / PCA9557 helpers ──

fn pca9557_write_byte(reg: u8, data: u8) void {
    const buf = [2]u8{ reg, data };
    i2c.masterWrite(b.i2c.port, b.lcd_cs_expander.i2c_addr, &buf, 100) catch {
        _ = esp_rom_printf("FATAL: I2C write failed\n");
        newlib.abort();
    };
}

fn pca9557_set_output(bit: u8, level: bool) void {
    var read_buf = [1]u8{0};
    const reg_buf = [1]u8{b.lcd_cs_expander.output_port_reg};
    i2c.masterWriteRead(b.i2c.port, b.lcd_cs_expander.i2c_addr, &reg_buf, &read_buf, 100) catch {
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

// ── drawing ──

fn fillRect(panel: *esp_lcd.Panel, x: i32, y: i32, w: i32, h: i32, color: u16) void {
    if (w <= 0 or h <= 0) return;
    var line: [b.lcd.h_res]u16 = undefined;
    const uw: usize = @intCast(w);
    for (0..uw) |i| {
        line[i] = color;
    }
    var row: i32 = 0;
    while (row < h) : (row += 1) {
        panel.drawBitmap(x, y + row, x + w, y + row + 1, @ptrCast(&line)) catch {
            _ = esp_rom_printf("lcd: drawBitmap error at row %d\n", y + row);
        };
    }
}

const DIGIT_FONT = [11][7]u8{
    .{ 0x0E, 0x11, 0x13, 0x15, 0x19, 0x11, 0x0E },
    .{ 0x04, 0x0C, 0x04, 0x04, 0x04, 0x04, 0x0E },
    .{ 0x0E, 0x11, 0x01, 0x02, 0x04, 0x08, 0x1F },
    .{ 0x1E, 0x01, 0x01, 0x0E, 0x01, 0x01, 0x1E },
    .{ 0x02, 0x06, 0x0A, 0x12, 0x1F, 0x02, 0x02 },
    .{ 0x1F, 0x10, 0x1E, 0x01, 0x01, 0x11, 0x0E },
    .{ 0x06, 0x08, 0x10, 0x1E, 0x11, 0x11, 0x0E },
    .{ 0x1F, 0x01, 0x02, 0x04, 0x08, 0x08, 0x08 },
    .{ 0x0E, 0x11, 0x11, 0x0E, 0x11, 0x11, 0x0E },
    .{ 0x0E, 0x11, 0x11, 0x0F, 0x01, 0x02, 0x0C },
    .{ 0x18, 0x19, 0x02, 0x04, 0x08, 0x13, 0x03 },
};

fn drawGlyph(panel: *esp_lcd.Panel, x: i32, y: i32, ch: u8, fg: u16, bg: u16, scale: i32) void {
    const glyph: ?*const [7]u8 = if (ch >= '0' and ch <= '9')
        &DIGIT_FONT[ch - '0']
    else if (ch == '%')
        &DIGIT_FONT[10]
    else
        null;
    const g = glyph orelse return;

    var row: i32 = 0;
    while (row < 7) : (row += 1) {
        var col: i32 = 0;
        while (col < 5) : (col += 1) {
            const shift: u3 = @intCast(4 - col);
            const on = (g[@intCast(row)] & (@as(u8, 1) << shift)) != 0;
            fillRect(panel, x + col * scale, y + row * scale, scale, scale, if (on) fg else bg);
        }
    }
}

fn drawText(panel: *esp_lcd.Panel, x: i32, y: i32, text: []const u8, fg: u16, bg: u16, scale: i32) void {
    var cursor = x;
    for (text) |ch| {
        drawGlyph(panel, cursor, y, ch, fg, bg, scale);
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

fn batteryColor(percent: u8) u16 {
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

fn drawBatteryShell(panel: *esp_lcd.Panel) void {
    fillRect(panel, 0, 0, b.lcd.h_res, b.lcd.v_res, COLOR_BLACK);
    fillRect(panel, BAT_BODY_X, BAT_BODY_Y, BAT_BODY_W, BAT_BODY_H, COLOR_WHITE);
    fillRect(panel, BAT_BODY_X + BAT_BODY_W, BAT_BODY_Y + 32, 14, 36, COLOR_WHITE);
    fillRect(panel, BAT_INNER_X, BAT_INNER_Y, BAT_INNER_W, BAT_INNER_H, COLOR_BLACK);
}

fn drawBatteryFill(panel: *esp_lcd.Panel, percent: u8) void {
    const fill_x = BAT_INNER_X + BAT_FILL_PAD;
    const fill_y = BAT_INNER_Y + BAT_FILL_PAD_V;
    const fill_h = BAT_INNER_H - BAT_FILL_PAD_V * 2;
    const fill_w = @divTrunc(BAT_MAX_FILL * @as(i32, percent), 100);

    fillRect(panel, fill_x, fill_y, BAT_MAX_FILL, fill_h, COLOR_BLACK);
    if (fill_w > 0) {
        fillRect(panel, fill_x, fill_y, fill_w, fill_h, batteryColor(percent));
    }

    fillRect(panel, TEXT_X, TEXT_Y, TEXT_CLEAR_W, TEXT_CLEAR_H, COLOR_BLACK);
    var text_buf: [8]u8 = undefined;
    const text = formatPercent(&text_buf, percent);
    drawText(panel, TEXT_X, TEXT_Y, text, COLOR_WHITE, COLOR_BLACK, TEXT_SCALE);
}

// ── entry ──

export fn zig_esp_main() callconv(.c) void {
    _ = esp_rom_printf("lcd_battery: starting (pure zig)\n");

    i2c.masterInit(b.i2c.port, b.i2c.sda, b.i2c.scl, b.i2c.freq_hz) catch {
        _ = esp_rom_printf("FATAL: I2C init failed\n");
        newlib.abort();
    };
    pca9557_write_byte(b.lcd_cs_expander.output_port_reg, b.lcd_cs_expander.init_output);
    pca9557_write_byte(b.lcd_cs_expander.config_port_reg, b.lcd_cs_expander.init_config);

    ledc.backlightInit(b.lcd.backlight, 0, 5000, true) catch {
        _ = esp_rom_printf("FATAL: LEDC init failed\n");
        newlib.abort();
    };

    const max_transfer: usize = @intCast(b.lcd.h_res * b.lcd.v_res * 2);
    var bus = esp_lcd.spi.Bus.init(.{
        .host_id = b.lcd.spi_host,
        .sclk_io_num = b.lcd.sclk,
        .mosi_io_num = b.lcd.mosi,
        .max_transfer_bytes = max_transfer,
        .dma_channel = SPI_DMA_CH_AUTO,
    }) catch {
        _ = esp_rom_printf("FATAL: SPI bus init failed\n");
        newlib.abort();
    };

    var io = esp_lcd.spi.PanelIo.init(&bus, .{
        .cs_io_num = b.lcd.cs,
        .dc_io_num = b.lcd.dc,
        .pclk_hz = b.lcd.pclk_hz,
        .spi_mode = b.lcd.spi_mode,
    }) catch {
        _ = esp_rom_printf("FATAL: Panel IO init failed\n");
        newlib.abort();
    };

    var panel = esp_lcd.driver.create(esp_lcd.driver.st7789, &io, .{
        .reset_gpio_num = b.lcd.rst,
        .bits_per_pixel = b.lcd.bpp,
    }) catch {
        _ = esp_rom_printf("FATAL: ST7789 panel create failed\n");
        newlib.abort();
    };

    lcdCheck(panel.reset());
    pca9557_set_output(b.lcd_cs_expander.cs_bit, false);
    lcdCheck(panel.init());
    lcdCheck(panel.invertColor(b.lcd.invert_color));
    lcdCheck(panel.swapXY(b.lcd.swap_xy));
    lcdCheck(panel.mirror(b.lcd.mirror_x, b.lcd.mirror_y));
    lcdCheck(panel.setDisplayEnabled(true));

    ledc.setDutyPercent(0, 100) catch |err| {
        _ = esp_rom_printf("WARN: LEDC set duty failed: %d\n", @intFromError(err));
    };

    var battery_adc = adc.Oneshot.init(b.battery_adc.unit, b.battery_adc.channel) catch {
        _ = esp_rom_printf("FATAL: ADC init failed\n");
        newlib.abort();
    };

    _ = esp_rom_printf("lcd_battery: init complete\n");
    _ = esp_rom_printf("heap: free=%u min_free=%u\n", heap.freeHeapSize(), heap.minimumFreeHeapSize());

    drawBatteryShell(&panel);

    var prev_percent: u8 = 0xFF;

    while (true) {
        var battery_mv: u32 = b.battery_adc.empty_mv;

        if (battery_adc.read()) |raw| {
            const clamped: u32 = if (raw < 0) 0 else @intCast(raw);
            const sensed_mv = clamped * 3300 / 4095;
            battery_mv = sensed_mv * b.battery_adc.divider_num / b.battery_adc.divider_den;
        } else |_| {}

        const percent = batteryPercent(battery_mv);

        if (percent != prev_percent) {
            drawBatteryFill(&panel, percent);
            prev_percent = percent;
        }

        _ = esp_rom_printf("lcd_battery: percent=%u mv=%u\n", @as(c_uint, percent), @as(c_uint, battery_mv));
        freertos.delay(2000);
    }
}
