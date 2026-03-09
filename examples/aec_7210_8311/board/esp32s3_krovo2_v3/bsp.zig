const esp = @import("esp");
const gpio = esp.component.esp_driver_gpio;
const audio_codec = esp.hal.audio_system.es7210_es8311;

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
};

pub const audio = audio_codec.Config{
    .mic_codec_address = 0x40,
    .spk_codec = .{
        .address = 0x18,
        .codec_mode = .both,
        .no_dac_ref = false,
    },
    .i2s = .{
        .port = 0,
        .mclk = 16,
        .bclk = 9,
        .ws = 45,
        .din = 10,
        .dout = 8,
    },
    .mics = .{ .@"24dB", .@"24dB", .ref, .disabled },
    .ref = .hw,
    .frame_samples = 256,
    .spk_initial_volume = 199,
};

pub const aec_mode = .voip_high_perf;

var pa_initialized: bool = false;

pub fn paEnable(en: bool) void {
    if (!pa_initialized) {
        gpio.setDirection(48, .output) catch {};
        pa_initialized = true;
    }
    gpio.setLevel(48, if (en) @as(u32, 1) else @as(u32, 0)) catch {};
}
