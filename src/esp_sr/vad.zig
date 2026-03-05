const esp_error = @import("utils").esp_error;

pub const EspError = esp_error.EspError;
pub const Error = esp_error.Error;
const check = esp_error.check;

pub const Mode = enum(i32) {
    /// Least aggressive, lowest false-rejection rate.
    quality = 0,
    low_bitrate = 1,
    aggressive = 2,
    /// Most aggressive, highest false-rejection rate.
    very_aggressive = 3,
};

pub const State = enum(i32) {
    silence = 0,
    speech = 1,
};

pub const Config = struct {
    mode: Mode = .aggressive,
    sample_rate: i32 = 16_000,
    one_frame_ms: i32 = 30,
    min_speech_ms: ?i32 = null,
    min_noise_ms: ?i32 = null,
};

extern fn espz_sr_vad_create(vad_mode: i32) ?*anyopaque;
extern fn espz_sr_vad_create_with_param(vad_mode: i32, sample_rate: i32, one_frame_ms: i32, min_speech_ms: i32, min_noise_ms: i32) ?*anyopaque;
extern fn espz_sr_vad_process(handle: *anyopaque, data: [*]i16, sample_rate: i32, one_frame_ms: i32, out_state: *i32) EspError;
extern fn espz_sr_vad_destroy(handle: *anyopaque) void;

pub const Vad = struct {
    handle: *anyopaque,
    sample_rate: i32,
    one_frame_ms: i32,

    pub fn init(cfg: Config) error{Fail}!Vad {
        const h = if (cfg.min_speech_ms != null and cfg.min_noise_ms != null)
            espz_sr_vad_create_with_param(
                @intFromEnum(cfg.mode),
                cfg.sample_rate,
                cfg.one_frame_ms,
                cfg.min_speech_ms.?,
                cfg.min_noise_ms.?,
            )
        else
            espz_sr_vad_create(@intFromEnum(cfg.mode));

        return .{
            .handle = h orelse return error.Fail,
            .sample_rate = cfg.sample_rate,
            .one_frame_ms = cfg.one_frame_ms,
        };
    }

    pub fn deinit(self: Vad) void {
        espz_sr_vad_destroy(self.handle);
    }

    /// Process one frame and return voice activity state.
    /// `data` must contain `sample_rate * one_frame_ms / 1000` samples.
    pub fn process(self: Vad, data: []i16) Error!State {
        var state: i32 = 0;
        try check(espz_sr_vad_process(self.handle, data.ptr, self.sample_rate, self.one_frame_ms, &state));
        return @enumFromInt(state);
    }
};
