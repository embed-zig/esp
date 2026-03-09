const esp_error = @import("../esp_error.zig");

pub const EspError = esp_error.EspError;
pub const Error = esp_error.Error;
const check = esp_error.check;

pub const Mode = enum(i32) {
    /// Optimized for speech recognition pipelines.
    sr = 0,
    /// Fixed digital gain mode 0.
    mode_0 = 1,
    /// Adaptive mode 1.
    mode_1 = 2,
    /// Adaptive mode 2.
    mode_2 = 3,
    /// Adaptive mode 3 (most aggressive).
    mode_3 = 4,
};

pub const Config = struct {
    mode: Mode = .sr,
    sample_rate: i32 = 16_000,
    gain_db: i32 = 15,
    limiter_enable: bool = true,
    /// Target output level in dBFS (negative value, e.g. -3 means -3 dBFS).
    target_level_dbfs: i32 = -3,
};

extern fn espz_sr_agc_open(agc_mode: i32, sample_rate: i32) ?*anyopaque;
extern fn espz_sr_agc_set_config(handle: *anyopaque, gain_db: i32, limiter_enable: i32, target_level_dbfs: i32) EspError;
extern fn espz_sr_agc_process(handle: *anyopaque, in_pcm: [*]i16, out_pcm: [*]i16, frame_size: i32, sample_rate: i32) EspError;
extern fn espz_sr_agc_close(handle: *anyopaque) void;

pub const Agc = struct {
    handle: *anyopaque,
    sample_rate: i32,

    pub fn init(cfg: Config) Error!Agc {
        const h = espz_sr_agc_open(
            @intFromEnum(cfg.mode),
            cfg.sample_rate,
        ) orelse return error.Fail;

        const self = Agc{ .handle = h, .sample_rate = cfg.sample_rate };

        try check(espz_sr_agc_set_config(
            h,
            cfg.gain_db,
            @intFromBool(cfg.limiter_enable),
            cfg.target_level_dbfs,
        ));

        return self;
    }

    pub fn deinit(self: Agc) void {
        espz_sr_agc_close(self.handle);
    }

    /// Process one frame. `input` and `output` must be `frame_size` samples.
    /// Typical frame_size: 160 (10 ms at 16 kHz).
    pub fn process(self: Agc, input: []i16, output: []i16, frame_size: i32) Error!void {
        try check(espz_sr_agc_process(self.handle, input.ptr, output.ptr, frame_size, self.sample_rate));
    }
};
