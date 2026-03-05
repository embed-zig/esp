const esp_error = @import("utils").esp_error;

pub const EspError = esp_error.EspError;
pub const Error = esp_error.Error;
const check = esp_error.check;

pub const sample_rate: i32 = 16_000;
pub const frame_size_ms: i32 = 16;

pub const ArrayType = enum(i32) {
    two_mic_line = 0,
    three_mic_circle = 1,
};

pub const OpMode = enum(i32) {
    normal = 0,
    wake_up_enhanced = 1,
};

pub const FilterStrength = enum(i32) {
    off = 0,
    mild = 1,
    medium = 2,
    aggressive = 3,
};

pub const Config = struct {
    array_type: ArrayType = .two_mic_line,
    /// Distance between neighboring microphones in mm.
    mic_distance_mm: f32 = 65.0,
    op_mode: OpMode = .normal,
    filter_strength: FilterStrength = .medium,
};

extern fn espz_sr_mase_create(
    sample_rate_hz: i32,
    frame_size_ms: i32,
    array_type: i32,
    mic_distance: f32,
    operating_mode: i32,
    filter_strength: i32,
) ?*anyopaque;
extern fn espz_sr_mase_process(handle: *anyopaque, input: [*]i16, output: [*]i16) EspError;
extern fn espz_sr_mase_destroy(handle: *anyopaque) void;

pub const Mase = struct {
    handle: *anyopaque,

    /// Create a MASE instance for dual/triple mic array speech enhancement.
    /// Fixed at 16 kHz sample rate, 16 ms frame size.
    pub fn init(cfg: Config) error{Fail}!Mase {
        const h = espz_sr_mase_create(
            sample_rate,
            frame_size_ms,
            @intFromEnum(cfg.array_type),
            cfg.mic_distance_mm,
            @intFromEnum(cfg.op_mode),
            @intFromEnum(cfg.filter_strength),
        ) orelse return error.Fail;
        return .{ .handle = h };
    }

    pub fn deinit(self: Mase) void {
        espz_sr_mase_destroy(self.handle);
    }

    /// Process one frame of interleaved multi-channel audio.
    /// `input`: interleaved mic samples (2ch or 3ch x 256 samples per frame).
    /// `output`: enhanced single-channel output (256 samples at 16 kHz / 16 ms).
    pub fn process(self: Mase, input: []i16, output: []i16) Error!void {
        try check(espz_sr_mase_process(self.handle, input.ptr, output.ptr));
    }
};
