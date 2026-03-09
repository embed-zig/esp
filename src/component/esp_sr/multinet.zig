const esp_error = @import("../esp_error.zig");

pub const EspError = esp_error.EspError;
pub const Error = esp_error.Error;
const check = esp_error.check;

pub const DetectState = enum(i32) {
    detecting = 0,
    detected = 1,
    timeout = 2,
};

pub const DetectResult = struct {
    command_id: i32,
    prob: f32,
    phrase: ?[*:0]const u8,
};

pub const Config = struct {
    model_name: [*:0]const u8,
    /// Max listening duration in ms after wake-up (0 = default).
    duration_ms: i32 = 6000,
};

extern fn espz_sr_mn_create(model_name: [*:0]const u8, duration_ms: i32) EspError;
extern fn espz_sr_mn_destroy() EspError;
extern fn espz_sr_mn_detect(samples: [*]i16, out_state: *i32) EspError;
extern fn espz_sr_mn_get_results(out_command_id: *i32, out_prob: *f32, out_string: *?[*:0]const u8) EspError;
extern fn espz_sr_mn_get_chunksize(out: *i32) EspError;
extern fn espz_sr_mn_commands_add(command_id: i32, phrase: [*:0]const u8) EspError;
extern fn espz_sr_mn_commands_update() EspError;
extern fn espz_sr_mn_commands_clear() EspError;

pub const MultiNet = struct {
    pub fn init(cfg: Config) Error!MultiNet {
        try check(espz_sr_mn_create(cfg.model_name, cfg.duration_ms));
        return .{};
    }

    pub fn deinit(_: MultiNet) Error!void {
        try check(espz_sr_mn_destroy());
    }

    /// Feed one chunk of audio and check for command detection.
    /// Buffer must be `getChunksize()` samples.
    pub fn detect(_: MultiNet, samples: []i16) Error!DetectState {
        var state: i32 = 0;
        try check(espz_sr_mn_detect(samples.ptr, &state));
        return @enumFromInt(state);
    }

    /// Retrieve recognition results after `detect` returns `.detected`.
    pub fn getResults(_: MultiNet) Error!DetectResult {
        var command_id: i32 = 0;
        var prob: f32 = 0;
        var phrase: ?[*:0]const u8 = null;
        try check(espz_sr_mn_get_results(&command_id, &prob, &phrase));
        return .{
            .command_id = command_id,
            .prob = prob,
            .phrase = phrase,
        };
    }

    /// Number of samples per detection chunk.
    pub fn getChunksize(_: MultiNet) Error!i32 {
        var out: i32 = 0;
        try check(espz_sr_mn_get_chunksize(&out));
        return out;
    }

    /// Add a speech command phrase mapped to an ID.
    pub fn addCommand(_: MultiNet, command_id: i32, phrase: [*:0]const u8) Error!void {
        try check(espz_sr_mn_commands_add(command_id, phrase));
    }

    /// Commit command list changes to the model.
    pub fn updateCommands(_: MultiNet) Error!void {
        try check(espz_sr_mn_commands_update());
    }

    /// Clear all registered commands.
    pub fn clearCommands(_: MultiNet) Error!void {
        try check(espz_sr_mn_commands_clear());
    }
};
