const esp_error = @import("../esp_error.zig");
pub const EspError = esp_error.EspError;
pub const Error = esp_error.Error;
const check = esp_error.check;

pub const clk_cfg_auto: i32 = 0;

extern fn espz_ledc_timer_config(
    speed_mode: i32,
    timer_num: i32,
    duty_resolution_bits: u8,
    freq_hz: u32,
    clk_cfg: i32,
) EspError;
extern fn espz_ledc_channel_config(
    gpio: i32,
    speed_mode: i32,
    channel: i32,
    timer_num: i32,
    invert: i32,
) EspError;
extern fn espz_ledc_set_duty(speed_mode: i32, channel: i32, duty: u32) EspError;
extern fn espz_ledc_update_duty(speed_mode: i32, channel: i32) EspError;
extern fn espz_ledc_set_duty_percent(
    speed_mode: i32,
    channel: i32,
    duty_resolution_bits: u8,
    percent: i32,
) EspError;
extern fn espz_ledc_fade_install() EspError;
extern fn espz_ledc_fade_to_duty(
    speed_mode: i32,
    channel: i32,
    duty: u32,
    duration_ms: u32,
    wait_done: i32,
) EspError;
extern fn espz_ledc_fade_to_percent(
    speed_mode: i32,
    channel: i32,
    duty_resolution_bits: u8,
    percent: i32,
    duration_ms: u32,
    wait_done: i32,
) EspError;

pub const TimerConfig = struct {
    speed_mode: i32 = 0,
    timer_num: i32 = 0,
    duty_resolution_bits: u8 = 10,
    freq_hz: u32 = 1000,
    clk_cfg: i32 = clk_cfg_auto,
};

pub const ChannelConfig = struct {
    gpio: i32,
    speed_mode: i32 = 0,
    channel: i32,
    timer_num: i32 = 0,
    invert: bool = false,
};

pub const Config = struct {
    gpio: i32,
    channel: i32,
    freq_hz: u32 = 1000,
    invert: bool = false,
    auto_install_fade: bool = true,
    speed_mode: i32 = 0,
    timer_num: i32 = 0,
    duty_resolution_bits: u8 = 10,
    clk_cfg: i32 = clk_cfg_auto,
};

pub const Ledc = struct {
    gpio: i32,
    channel: i32,
    freq_hz: u32,
    invert: bool,
    speed_mode: i32,
    timer_num: i32,
    duty_resolution_bits: u8,

    pub fn init(cfg: Config) Error!Ledc {
        try configureTimer(.{
            .speed_mode = cfg.speed_mode,
            .timer_num = cfg.timer_num,
            .duty_resolution_bits = cfg.duty_resolution_bits,
            .freq_hz = cfg.freq_hz,
            .clk_cfg = cfg.clk_cfg,
        });
        try configureChannel(.{
            .gpio = cfg.gpio,
            .speed_mode = cfg.speed_mode,
            .channel = cfg.channel,
            .timer_num = cfg.timer_num,
            .invert = cfg.invert,
        });
        if (cfg.auto_install_fade) {
            try installFadeService();
        }
        return .{
            .gpio = cfg.gpio,
            .channel = cfg.channel,
            .freq_hz = cfg.freq_hz,
            .invert = cfg.invert,
            .speed_mode = cfg.speed_mode,
            .timer_num = cfg.timer_num,
            .duty_resolution_bits = cfg.duty_resolution_bits,
        };
    }

    pub fn setDuty(self: Ledc, duty: u32) Error!void {
        try setDutyImpl(self.speed_mode, self.channel, duty);
    }

    pub fn setDutyPercent(self: Ledc, percent: u8) Error!void {
        try setDutyPercentWithResolution(self.speed_mode, self.channel, self.duty_resolution_bits, percent);
    }

    pub fn fadeToDuty(self: Ledc, duty: u32, duration_ms: u32, wait_done: bool) Error!void {
        try fadeToDutyImpl(self.speed_mode, self.channel, duty, duration_ms, wait_done);
    }

    pub fn fadeToPercent(self: Ledc, percent: u8, duration_ms: u32, wait_done: bool) Error!void {
        try fadeToPercentWithResolution(
            self.speed_mode,
            self.channel,
            self.duty_resolution_bits,
            percent,
            duration_ms,
            wait_done,
        );
    }
};

pub fn configureTimer(cfg: TimerConfig) Error!void {
    try check(espz_ledc_timer_config(
        cfg.speed_mode,
        cfg.timer_num,
        cfg.duty_resolution_bits,
        cfg.freq_hz,
        cfg.clk_cfg,
    ));
}

pub fn configureChannel(cfg: ChannelConfig) Error!void {
    try check(espz_ledc_channel_config(
        cfg.gpio,
        cfg.speed_mode,
        cfg.channel,
        cfg.timer_num,
        if (cfg.invert) 1 else 0,
    ));
}

pub fn setDuty(speed_mode: i32, channel: i32, duty: u32) Error!void {
    try setDutyImpl(speed_mode, channel, duty);
}

fn setDutyImpl(speed_mode: i32, channel: i32, duty: u32) Error!void {
    try check(espz_ledc_set_duty(speed_mode, channel, duty));
    try check(espz_ledc_update_duty(speed_mode, channel));
}

pub fn setDutyPercentWithResolution(
    speed_mode: i32,
    channel: i32,
    duty_resolution_bits: u8,
    percent: u8,
) Error!void {
    try check(espz_ledc_set_duty_percent(
        speed_mode,
        channel,
        duty_resolution_bits,
        @as(i32, percent),
    ));
}

pub fn installFadeService() Error!void {
    try check(espz_ledc_fade_install());
}

pub fn fadeToDuty(speed_mode: i32, channel: i32, duty: u32, duration_ms: u32, wait_done: bool) Error!void {
    try fadeToDutyImpl(speed_mode, channel, duty, duration_ms, wait_done);
}

fn fadeToDutyImpl(speed_mode: i32, channel: i32, duty: u32, duration_ms: u32, wait_done: bool) Error!void {
    try check(espz_ledc_fade_to_duty(
        speed_mode,
        channel,
        duty,
        duration_ms,
        if (wait_done) 1 else 0,
    ));
}

pub fn fadeToPercentWithResolution(
    speed_mode: i32,
    channel: i32,
    duty_resolution_bits: u8,
    percent: u8,
    duration_ms: u32,
    wait_done: bool,
) Error!void {
    try check(espz_ledc_fade_to_percent(
        speed_mode,
        channel,
        duty_resolution_bits,
        @as(i32, percent),
        duration_ms,
        if (wait_done) 1 else 0,
    ));
}
