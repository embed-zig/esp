const board = @import("board");
const esp_lcd = @import("esp_lcd");
const rom = @import("esp_rom");
const newlib = @import("newlib");
const freertos = @import("freertos");
const heap = @import("heap");
const i2c = @import("esp_driver_i2c");
const ledc_mod = @import("esp_driver_ledc");
const ledc = ledc_mod.ledc;
const adc = @import("esp_adc");

const b = board.pins;

const LCD_W: usize = b.lcd.h_res;
const LCD_H: usize = b.lcd.v_res;
const FB_PIXELS = LCD_W * LCD_H;

const SPI_DMA_CH_AUTO: i32 = 3;
const MALLOC_CAP_DMA: u32 = 4;

const COLOR_BLACK: u16 = 0x0000;
const COLOR_WHITE: u16 = 0xFFFF;
const COLOR_GREEN: u16 = 0x07E0;
const COLOR_ORANGE: u16 = 0xFD20;
const COLOR_RED: u16 = 0xF800;

const esp_rom_printf = rom.esp_rom_printf;

const I2C_TIMEOUT: u32 = 100;

fn lcdCheck(result: esp_lcd.Error!void) void {
    result catch {
        _ = esp_rom_printf("FATAL LCD error\n");
        newlib.abort();
    };
}

var g_i2c: i2c.I2cMaster = undefined;

fn pca9557_write_byte(reg: u8, data: u8) void {
    g_i2c.write(b.lcd_cs_expander.i2c_addr, &.{ reg, data }, I2C_TIMEOUT) catch {
        _ = esp_rom_printf("FATAL: I2C write failed\n");
        newlib.abort();
    };
}

fn pca9557_set_output(bit: u8, level: bool) void {
    var read_buf: [1]u8 = undefined;
    g_i2c.writeRead(b.lcd_cs_expander.i2c_addr, &.{b.lcd_cs_expander.output_port_reg}, &read_buf, I2C_TIMEOUT) catch {
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

var fb: [*]u16 = undefined;

fn fbSet(x: usize, y: usize, color: u16) void {
    if (x < LCD_W and y < LCD_H) {
        fb[y * LCD_W + x] = color;
    }
}

fn fbFillRect(x: i32, y: i32, w: i32, h: i32, color: u16) void {
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

fn flush(panel: *esp_lcd.Panel) void {
    panel.drawBitmap(0, 0, @intCast(LCD_W), @intCast(LCD_H), @ptrCast(fb)) catch {};
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

fn fbDrawGlyph(x: i32, y: i32, ch: u8, fg: u16, bg: u16, scale: i32) void {
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

fn fbDrawText(x: i32, y: i32, text: []const u8, fg: u16, bg: u16, scale: i32) void {
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

var g_spi_bus: esp_lcd.spi.Bus = undefined;
var g_io: esp_lcd.spi.PanelIo = undefined;
var g_panel: esp_lcd.Panel = undefined;

export fn zig_esp_main() callconv(.c) void {
    _ = esp_rom_printf("lcd_battery: starting\n");

    const fb_ptr = heap.capsMalloc(FB_PIXELS * 2, MALLOC_CAP_DMA) orelse {
        _ = esp_rom_printf("FATAL: framebuffer alloc failed (%u bytes)\n", @as(c_uint, FB_PIXELS * 2));
        newlib.abort();
    };
    fb = @ptrCast(@alignCast(fb_ptr));
    _ = esp_rom_printf("lcd_battery: framebuffer allocated (%u bytes)\n", @as(c_uint, FB_PIXELS * 2));

    g_i2c = i2c.I2cMaster.init(.{
        .port = b.i2c.port,
        .sda = b.i2c.sda,
        .scl = b.i2c.scl,
        .freq_hz = b.i2c.freq_hz,
    }) catch {
        _ = esp_rom_printf("FATAL: I2C init failed\n");
        newlib.abort();
    };
    pca9557_write_byte(b.lcd_cs_expander.output_port_reg, b.lcd_cs_expander.init_output);
    pca9557_write_byte(b.lcd_cs_expander.config_port_reg, b.lcd_cs_expander.init_config);

    ledc.configureTimer(.{
        .speed_mode = 0,
        .timer_num = 0,
        .duty_resolution_bits = 10,
        .freq_hz = 5000,
        .clk_cfg = ledc.clk_cfg_auto,
    }) catch {
        _ = esp_rom_printf("FATAL: LEDC timer config failed\n");
        newlib.abort();
    };
    ledc.configureChannel(.{
        .gpio = b.lcd.backlight,
        .speed_mode = 0,
        .channel = 0,
        .timer_num = 0,
        .invert = true,
    }) catch {
        _ = esp_rom_printf("FATAL: LEDC channel config failed\n");
        newlib.abort();
    };

    const max_transfer: usize = @intCast(b.lcd.h_res * b.lcd.v_res * 2);
    g_spi_bus = esp_lcd.spi.Bus.init(.{
        .host_id = b.lcd.spi_host,
        .sclk_io_num = b.lcd.sclk,
        .mosi_io_num = b.lcd.mosi,
        .max_transfer_bytes = max_transfer,
        .dma_channel = SPI_DMA_CH_AUTO,
    }) catch {
        _ = esp_rom_printf("FATAL: SPI bus init failed\n");
        newlib.abort();
    };

    g_io = esp_lcd.spi.PanelIo.init(&g_spi_bus, .{
        .cs_io_num = b.lcd.cs,
        .dc_io_num = b.lcd.dc,
        .pclk_hz = b.lcd.pclk_hz,
        .spi_mode = b.lcd.spi_mode,
    }) catch {
        _ = esp_rom_printf("FATAL: Panel IO init failed\n");
        newlib.abort();
    };

    g_panel = esp_lcd.driver.create(esp_lcd.driver.st7789, &g_io, .{
        .reset_gpio_num = b.lcd.rst,
        .bits_per_pixel = b.lcd.bpp,
    }) catch {
        _ = esp_rom_printf("FATAL: ST7789 panel create failed\n");
        newlib.abort();
    };

    lcdCheck(g_panel.reset());
    pca9557_set_output(b.lcd_cs_expander.cs_bit, false);
    lcdCheck(g_panel.init());
    lcdCheck(g_panel.invertColor(b.lcd.invert_color));
    lcdCheck(g_panel.swapXY(b.lcd.swap_xy));
    lcdCheck(g_panel.mirror(b.lcd.mirror_x, b.lcd.mirror_y));
    lcdCheck(g_panel.setDisplayEnabled(true));

    ledc.setDutyPercentWithResolution(0, 0, 10, 100) catch |err| {
        _ = esp_rom_printf("WARN: LEDC set duty failed: %d\n", @intFromError(err));
    };

    var battery_adc = adc.Oneshot.init(b.battery_adc.unit, b.battery_adc.channel) catch {
        _ = esp_rom_printf("FATAL: ADC init failed\n");
        newlib.abort();
    };

    _ = esp_rom_printf("lcd_battery: init complete\n");
    _ = esp_rom_printf("heap: free=%u min_free=%u\n", heap.freeHeapSize(), heap.minimumFreeHeapSize());

    drawBatteryShell();
    flush(&g_panel);

    var prev_percent: u8 = 0xFF;
    var uptime: u32 = 0;

    while (true) {
        var battery_mv: u32 = b.battery_adc.empty_mv;

        if (battery_adc.read()) |raw| {
            const clamped: u32 = if (raw < 0) 0 else @intCast(raw);
            const sensed_mv = clamped * 3300 / 4095;
            battery_mv = sensed_mv * b.battery_adc.divider_num / b.battery_adc.divider_den;
        } else |_| {}

        const percent = batteryPercent(battery_mv);

        if (percent != prev_percent) {
            drawBatteryFill(percent);
            prev_percent = percent;
        }

        fbDrawUptime(uptime);
        uptime += 1;

        flush(&g_panel);

        _ = esp_rom_printf("lcd_battery: percent=%u mv=%u uptime=%u\n", @as(c_uint, percent), @as(c_uint, battery_mv), uptime);
        freertos.delay(100);
    }
}
