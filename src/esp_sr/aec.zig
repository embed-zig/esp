const esp_error = @import("utils").esp_error;

pub const EspError = esp_error.EspError;
pub const Error = esp_error.Error;
const check = esp_error.check;

pub const Mode = enum(i32) {
    sr_low_cost = 0,
    sr_high_perf = 1,
    voip_low_cost = 2,
    voip_high_perf = 3,
};

pub const Config = struct {
    sample_rate: i32 = 16_000,
    frame_length: i32 = 512,
    channel_num: i32 = 1,
    mode: Mode = .sr_high_perf,
};

extern fn espz_sr_aec_create(sample_rate: i32, frame_length: i32, channel_num: i32, mode: i32) ?*anyopaque;
extern fn espz_sr_aec_process(handle: *anyopaque, indata: [*]i16, refdata: [*]i16, outdata: [*]i16) EspError;
extern fn espz_sr_aec_get_chunksize(handle: *anyopaque, out: *i32) EspError;
extern fn espz_sr_aec_destroy(handle: *anyopaque) void;

pub const Aec = struct {
    handle: *anyopaque,

    pub fn init(cfg: Config) error{Fail}!Aec {
        const h = espz_sr_aec_create(
            cfg.sample_rate,
            cfg.frame_length,
            cfg.channel_num,
            @intFromEnum(cfg.mode),
        ) orelse return error.Fail;
        return .{ .handle = h };
    }

    pub fn deinit(self: Aec) void {
        espz_sr_aec_destroy(self.handle);
    }

    /// Process one frame: cancel echo from `ref` in `input`, write result to `output`.
    /// All buffers must be at least `getChunksize()` samples.
    pub fn process(self: Aec, input: []i16, ref: []i16, output: []i16) Error!void {
        try check(espz_sr_aec_process(self.handle, input.ptr, ref.ptr, output.ptr));
    }

    /// Number of samples per processing frame.
    pub fn getChunksize(self: Aec) Error!i32 {
        var out: i32 = 0;
        try check(espz_sr_aec_get_chunksize(self.handle, &out));
        return out;
    }
};
