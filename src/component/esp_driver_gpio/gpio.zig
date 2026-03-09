const esp_error = @import("../esp_error.zig");
pub const EspError = esp_error.EspError;
pub const Error = esp_error.Error;
const check = esp_error.check;

pub const GpioMode = enum(i32) {
    disable = 0,
    input = 1,
    output = 2,
    output_od = 6,
    input_output_od = 7,
    input_output = 3,
};

pub const GpioPull = enum(i32) {
    pullup_only = 0,
    pulldown_only = 1,
    pullup_pulldown = 2,
    floating = 3,
};

extern fn espz_gpio_set_direction(pin: i32, mode: i32) EspError;
extern fn espz_gpio_set_level(pin: i32, level: u32) EspError;
extern fn espz_gpio_get_level(pin: i32) i32;
extern fn espz_gpio_set_pull_mode(pin: i32, pull: i32) EspError;
extern fn espz_gpio_reset_pin(pin: i32) EspError;

pub fn setDirection(pin: i32, mode: GpioMode) Error!void {
    try check(espz_gpio_set_direction(pin, @intFromEnum(mode)));
}

pub fn setLevel(pin: i32, level: u1) Error!void {
    try check(espz_gpio_set_level(pin, @as(u32, level)));
}

pub fn getLevel(pin: i32) u1 {
    const raw = espz_gpio_get_level(pin);
    return if (raw != 0) 1 else 0;
}

pub fn setPullMode(pin: i32, pull: GpioPull) Error!void {
    try check(espz_gpio_set_pull_mode(pin, @intFromEnum(pull)));
}

pub fn resetPin(pin: i32) Error!void {
    try check(espz_gpio_reset_pin(pin));
}
