pub const config = @import("build_config").config;

pub const pins = .{
    .i2c = .{
        .port = 0,
        .sda = 17,
        .scl = 18,
        .freq_hz = @as(u32, 100_000),
    },
    .i2s = .{
        .port = 0,
        .mclk = 16,
        .bclk = 9,
        .ws = 45,
        .din = 10,
        .dout = 8,
        .sample_rate = @as(u32, 16_000),
    },
    .es7210 = .{
        .i2c_addr = @as(u7, 0x40),
    },
    .es8311 = .{
        .i2c_addr = @as(u7, 0x18),
    },
    .pa = .{
        .gpio = 48,
    },
};
