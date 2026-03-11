pub const config = @import("build_config").config;

pub const pins = .{
    .led_strip = .{
        .gpio = @as(i32, 48),
        .max_leds = @as(u32, 1),
    },
    .boot_button = .{
        .gpio = @as(i32, 0),
    },
};
