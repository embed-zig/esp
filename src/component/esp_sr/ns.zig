const esp_error = @import("../esp_error.zig");

pub const EspError = esp_error.EspError;
pub const Error = esp_error.Error;
const check = esp_error.check;

pub const FrameLength = enum(i32) {
    ms10 = 10,
    ms20 = 20,
    ms30 = 30,
};

pub const Mode = enum(i32) {
    mild = 0,
    medium = 1,
    aggressive = 2,
};

pub const Config = struct {
    frame_length: FrameLength = .ms10,
    mode: ?Mode = null,
    sample_rate: i32 = 16_000,
};

extern fn espz_sr_ns_create(frame_length_ms: i32) ?*anyopaque;
extern fn espz_sr_ns_pro_create(frame_length_ms: i32, mode: i32, sample_rate: i32) ?*anyopaque;
extern fn espz_sr_ns_process(handle: *anyopaque, indata: [*]i16, outdata: [*]i16) EspError;
extern fn espz_sr_ns_destroy(handle: *anyopaque) void;

pub const Ns = struct {
    handle: *anyopaque,

    /// Create a noise suppression instance.
    /// If `cfg.mode` is set, uses the pro variant with configurable aggressiveness.
    pub fn init(cfg: Config) error{Fail}!Ns {
        const h = if (cfg.mode) |mode|
            espz_sr_ns_pro_create(
                @intFromEnum(cfg.frame_length),
                @intFromEnum(mode),
                cfg.sample_rate,
            )
        else
            espz_sr_ns_create(@intFromEnum(cfg.frame_length));

        return .{ .handle = h orelse return error.Fail };
    }

    pub fn deinit(self: Ns) void {
        espz_sr_ns_destroy(self.handle);
    }

    /// Process one frame of audio. `input` and `output` must be frame-length samples.
    pub fn process(self: Ns, input: []i16, output: []i16) Error!void {
        try check(espz_sr_ns_process(self.handle, input.ptr, output.ptr));
    }
};
