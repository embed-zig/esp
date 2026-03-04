pub const EspError = i32;
pub const esp_ok: EspError = 0;

pub const Error = error{ EspIdfFailure, InvalidArgument, NotSupported };

pub fn check(result: EspError) Error!void {
    if (result == esp_ok) return;
    if (result == 0x102) return error.InvalidArgument;
    if (result == 0x10C) return error.NotSupported;
    return error.EspIdfFailure;
}

pub const LedModel = enum(u32) {
    ws2812 = 0,
    sk6812 = 1,
    ws2811 = 2,
    ws2816 = 3,
};

/// Mirrors `led_color_component_format_t` from ESP-IDF.
/// The union is a packed bitfield; we expose it as a Zig packed struct
/// and provide pre-built constants matching the C helper macros.
pub const ColorComponentFormat = packed struct(u32) {
    r_pos: u2,
    g_pos: u2,
    b_pos: u2,
    w_pos: u2,
    reserved: u19 = 0,
    bytes_per_color: u2,
    num_components: u3,

    /// GRB order, 8-bit, 3 components (WS2812 default)
    pub const grb: ColorComponentFormat = .{ .r_pos = 1, .g_pos = 0, .b_pos = 2, .w_pos = 3, .bytes_per_color = 1, .num_components = 3 };
    /// GRB order, 16-bit, 3 components
    pub const grb_16: ColorComponentFormat = .{ .r_pos = 1, .g_pos = 0, .b_pos = 2, .w_pos = 3, .bytes_per_color = 2, .num_components = 3 };
    /// GRBW order, 8-bit, 4 components (SK6812 RGBW)
    pub const grbw: ColorComponentFormat = .{ .r_pos = 1, .g_pos = 0, .b_pos = 2, .w_pos = 3, .bytes_per_color = 1, .num_components = 4 };
    /// GRBW order, 16-bit, 4 components
    pub const grbw_16: ColorComponentFormat = .{ .r_pos = 1, .g_pos = 0, .b_pos = 2, .w_pos = 3, .bytes_per_color = 2, .num_components = 4 };
    /// RGB order, 8-bit, 3 components
    pub const rgb: ColorComponentFormat = .{ .r_pos = 0, .g_pos = 1, .b_pos = 2, .w_pos = 3, .bytes_per_color = 1, .num_components = 3 };
    /// RGB order, 16-bit, 3 components
    pub const rgb_16: ColorComponentFormat = .{ .r_pos = 0, .g_pos = 1, .b_pos = 2, .w_pos = 3, .bytes_per_color = 2, .num_components = 3 };
    /// RGBW order, 8-bit, 4 components
    pub const rgbw: ColorComponentFormat = .{ .r_pos = 0, .g_pos = 1, .b_pos = 2, .w_pos = 3, .bytes_per_color = 1, .num_components = 4 };
    /// RGBW order, 16-bit, 4 components
    pub const rgbw_16: ColorComponentFormat = .{ .r_pos = 0, .g_pos = 1, .b_pos = 2, .w_pos = 3, .bytes_per_color = 2, .num_components = 4 };

    pub fn toFormatId(self: ColorComponentFormat) u32 {
        return @bitCast(self);
    }
};

pub const RmtConfig = struct {
    resolution_hz: u32 = 10_000_000,
    mem_block_symbols: usize = 0,
    with_dma: bool = false,
};

pub const SpiConfig = struct {
    spi_bus: i32 = 2,
    with_dma: bool = true,
};

pub const StripConfig = struct {
    gpio_num: i32,
    max_leds: u32,
    led_model: LedModel = .ws2812,
    color_format: ColorComponentFormat = ColorComponentFormat.grb,
    invert_out: bool = false,
};

pub const LedStrip = struct {
    handle: *anyopaque,

    extern fn espz_led_strip_new_rmt(
        gpio_num: i32,
        max_leds: u32,
        led_model: u32,
        color_format_id: u32,
        invert_out: bool,
        resolution_hz: u32,
        mem_block_symbols: usize,
        with_dma: bool,
        out_handle: *?*anyopaque,
    ) EspError;

    extern fn espz_led_strip_new_spi(
        gpio_num: i32,
        max_leds: u32,
        led_model: u32,
        color_format_id: u32,
        invert_out: bool,
        spi_bus: i32,
        with_dma: bool,
        out_handle: *?*anyopaque,
    ) EspError;

    extern fn espz_led_strip_set_pixel(handle: *anyopaque, index: u32, r: u32, g: u32, b: u32) EspError;
    extern fn espz_led_strip_set_pixel_rgbw(handle: *anyopaque, index: u32, r: u32, g: u32, b: u32, w: u32) EspError;
    extern fn espz_led_strip_set_pixel_hsv(handle: *anyopaque, index: u32, hue: u16, saturation: u8, value: u8) EspError;
    extern fn espz_led_strip_refresh(handle: *anyopaque) EspError;
    extern fn espz_led_strip_clear(handle: *anyopaque) EspError;
    extern fn espz_led_strip_del(handle: *anyopaque) EspError;

    pub fn initRmt(cfg: StripConfig, rmt: RmtConfig) Error!LedStrip {
        var handle: ?*anyopaque = null;
        try check(espz_led_strip_new_rmt(
            cfg.gpio_num,
            cfg.max_leds,
            @intFromEnum(cfg.led_model),
            cfg.color_format.toFormatId(),
            cfg.invert_out,
            rmt.resolution_hz,
            rmt.mem_block_symbols,
            rmt.with_dma,
            &handle,
        ));
        return .{ .handle = handle.? };
    }

    pub fn initSpi(cfg: StripConfig, spi: SpiConfig) Error!LedStrip {
        var handle: ?*anyopaque = null;
        try check(espz_led_strip_new_spi(
            cfg.gpio_num,
            cfg.max_leds,
            @intFromEnum(cfg.led_model),
            cfg.color_format.toFormatId(),
            cfg.invert_out,
            spi.spi_bus,
            spi.with_dma,
            &handle,
        ));
        return .{ .handle = handle.? };
    }

    pub fn deinit(self: LedStrip) Error!void {
        try check(espz_led_strip_del(self.handle));
    }

    pub fn setPixel(self: LedStrip, index: u32, r: u8, g: u8, b: u8) Error!void {
        try check(espz_led_strip_set_pixel(self.handle, index, r, g, b));
    }

    pub fn setPixelRgbw(self: LedStrip, index: u32, r: u8, g: u8, b: u8, w: u8) Error!void {
        try check(espz_led_strip_set_pixel_rgbw(self.handle, index, r, g, b, w));
    }

    pub fn setPixelHsv(self: LedStrip, index: u32, hue: u16, saturation: u8, value: u8) Error!void {
        try check(espz_led_strip_set_pixel_hsv(self.handle, index, hue, saturation, value));
    }

    pub fn refresh(self: LedStrip) Error!void {
        try check(espz_led_strip_refresh(self.handle));
    }

    pub fn clear(self: LedStrip) Error!void {
        try check(espz_led_strip_clear(self.handle));
    }
};

test "ColorComponentFormat bitcast matches expected layout" {
    const std = @import("std");
    const grb_id = ColorComponentFormat.grb.toFormatId();
    try std.testing.expect(grb_id != 0);

    const rgb_id = ColorComponentFormat.rgb.toFormatId();
    try std.testing.expect(grb_id != rgb_id);
}

test "LedStrip API symbols exist" {
    _ = &LedStrip.initRmt;
    _ = &LedStrip.initSpi;
    _ = &LedStrip.deinit;
    _ = &LedStrip.setPixel;
    _ = &LedStrip.setPixelRgbw;
    _ = &LedStrip.setPixelHsv;
    _ = &LedStrip.refresh;
    _ = &LedStrip.clear;
}
