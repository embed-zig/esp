pub const EspError = i32;
pub const esp_ok: EspError = 0;

pub const Error = error{ EspIdfFailure, InvalidArgument };

pub fn check(result: EspError) Error!void {
    if (result != esp_ok) return error.EspIdfFailure;
}

extern fn espz_ledc_backlight_init(gpio: i32, channel: i32, freq: u32, invert: i32) EspError;
extern fn espz_ledc_set_duty_percent(channel: i32, percent: i32) EspError;

pub fn backlightInit(gpio: i32, channel: i32, freq: u32, invert: bool) Error!void {
    try check(espz_ledc_backlight_init(gpio, channel, freq, if (invert) 1 else 0));
}

pub fn setDutyPercent(channel: i32, percent: u8) Error!void {
    try check(espz_ledc_set_duty_percent(channel, @as(i32, percent)));
}
