pub const config = @import("build_config").config;

pub const pins = .{
    .i2c = .{
        .port = 0,
        .sda = 1,
        .scl = 2,
        .freq_hz = @as(u32, 100_000),
    },
    .i2s = .{
        .port = 0,
        .mclk = 38,
        .bclk = 14,
        .ws = 13,
        .din = 12,
        .dout = 45,
        .sample_rate = @as(u32, 16_000),
    },
    .es7210 = .{
        .i2c_addr = @as(u7, 0x41),
    },
    .es8311 = .{
        .i2c_addr = @as(u7, 0x18),
    },
    .pa = .{
        .i2c_addr = @as(u8, 0x19),
        .output_port_reg = @as(u8, 0x01),
        .config_port_reg = @as(u8, 0x03),
        .pa_bit = @as(u8, 0x02),
        .init_output = @as(u8, 0x05),
        .init_config = @as(u8, 0xF8),
    },
    .lcd = .{
        .spi_host = 2,
        .sclk = 41,
        .mosi = 40,
        .cs = -1,
        .dc = 39,
        .rst = -1,
        .backlight = 42,
        .h_res = 320,
        .v_res = 240,
        .bpp = @as(u8, 16),
        .pclk_hz = @as(u32, 80_000_000),
        .spi_mode = @as(u8, 2),
        .invert_color = true,
        .swap_xy = true,
        .mirror_x = true,
        .mirror_y = false,
    },
    .lcd_cs_expander = .{
        .i2c_addr = @as(u8, 0x19),
        .output_port_reg = @as(u8, 0x01),
        .config_port_reg = @as(u8, 0x03),
        .cs_bit = @as(u8, 0x01),
        .init_output = @as(u8, 0x05),
        .init_config = @as(u8, 0xF8),
    },
};
