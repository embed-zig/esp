const esp_error = @import("utils").esp_error;

pub const EspError = esp_error.EspError;
pub const Error = esp_error.Error;
const check = esp_error.check;

pub const AfeType = enum(i32) {
    sr = 0,
    voice_communication = 1,
    voice_communication_8k = 2,
};

pub const AfeMode = enum(i32) {
    low_cost = 0,
    high_perf = 1,
};

pub const WakeupState = enum(i32) {
    no_detect = 0,
    channel_verified = 1,
    detected = 2,
};

pub const VadState = enum(i32) {
    silence = 0,
    speech = 1,
};

pub const Config = struct {
    afe_type: AfeType = .sr,
    afe_mode: AfeMode = .high_perf,
    input_format: [:0]const u8 = "MR",
    wakenet_en: bool = true,
    aec_en: bool = true,
    ns_en: bool = true,
    agc_en: bool = true,
    vad_en: bool = true,
};

pub const FetchResult = struct {
    wakeup_state: WakeupState,
    vad_state: VadState,
    data: [*]const i16,
    data_size: usize,
    channel_id: i32,
};

extern fn espz_sr_afe_create(
    afe_type: i32,
    afe_mode: i32,
    input_format: [*:0]const u8,
    wakenet_en: i32,
    aec_en: i32,
    ns_en: i32,
    agc_en: i32,
    vad_en: i32,
) EspError;
extern fn espz_sr_afe_destroy() EspError;
extern fn espz_sr_afe_feed(audio: [*]const i16, len: i32) EspError;
extern fn espz_sr_afe_fetch(
    out_wakeup_state: *i32,
    out_vad_state: *i32,
    out_data_size: *i32,
    out_data_ptr: *[*]i16,
    out_channel_id: *i32,
    ticks_to_wait: i32,
) EspError;
extern fn espz_sr_afe_get_feed_chunksize(out: *i32) EspError;
extern fn espz_sr_afe_get_channel_num(out: *i32) EspError;
extern fn espz_sr_afe_get_sample_rate(out: *i32) EspError;
extern fn espz_sr_afe_enable_wakenet() EspError;
extern fn espz_sr_afe_disable_wakenet() EspError;
extern fn espz_sr_afe_enable_aec() EspError;
extern fn espz_sr_afe_disable_aec() EspError;
extern fn espz_sr_afe_enable_ns() EspError;
extern fn espz_sr_afe_disable_ns() EspError;
extern fn espz_sr_afe_enable_agc() EspError;
extern fn espz_sr_afe_disable_agc() EspError;

pub const Afe = struct {
    pub fn init(cfg: Config) Error!Afe {
        try check(espz_sr_afe_create(
            @intFromEnum(cfg.afe_type),
            @intFromEnum(cfg.afe_mode),
            cfg.input_format.ptr,
            @intFromBool(cfg.wakenet_en),
            @intFromBool(cfg.aec_en),
            @intFromBool(cfg.ns_en),
            @intFromBool(cfg.agc_en),
            @intFromBool(cfg.vad_en),
        ));
        return .{};
    }

    pub fn deinit(_: Afe) Error!void {
        try check(espz_sr_afe_destroy());
    }

    /// Feed interleaved PCM audio (mic channels + ref channels).
    /// Buffer length must match `getFeedChunksize() * channel_count`.
    pub fn feed(_: Afe, audio: []const i16) Error!void {
        try check(espz_sr_afe_feed(audio.ptr, @intCast(audio.len)));
    }

    /// Fetch processed single-channel output. Returns null if no data available.
    pub fn fetch(_: Afe) Error!FetchResult {
        return fetchInternal(-1);
    }

    /// Fetch with a FreeRTOS tick timeout.
    pub fn fetchWithDelay(_: Afe, ticks_to_wait: u32) Error!FetchResult {
        return fetchInternal(@intCast(ticks_to_wait));
    }

    fn fetchInternal(ticks_to_wait: i32) Error!FetchResult {
        var wakeup_state: i32 = 0;
        var vad_state: i32 = 0;
        var data_size: i32 = 0;
        var data_ptr: [*]i16 = undefined;
        var channel_id: i32 = 0;

        try check(espz_sr_afe_fetch(
            &wakeup_state,
            &vad_state,
            &data_size,
            &data_ptr,
            &channel_id,
            ticks_to_wait,
        ));

        return .{
            .wakeup_state = @enumFromInt(wakeup_state),
            .vad_state = @enumFromInt(vad_state),
            .data = data_ptr,
            .data_size = @intCast(data_size),
            .channel_id = channel_id,
        };
    }

    pub fn getFeedChunksize(_: Afe) Error!i32 {
        var out: i32 = 0;
        try check(espz_sr_afe_get_feed_chunksize(&out));
        return out;
    }

    pub fn getChannelNum(_: Afe) Error!i32 {
        var out: i32 = 0;
        try check(espz_sr_afe_get_channel_num(&out));
        return out;
    }

    pub fn getSampleRate(_: Afe) Error!i32 {
        var out: i32 = 0;
        try check(espz_sr_afe_get_sample_rate(&out));
        return out;
    }

    pub fn enableWakenet(_: Afe) Error!void {
        try check(espz_sr_afe_enable_wakenet());
    }

    pub fn disableWakenet(_: Afe) Error!void {
        try check(espz_sr_afe_disable_wakenet());
    }

    pub fn enableAec(_: Afe) Error!void {
        try check(espz_sr_afe_enable_aec());
    }

    pub fn disableAec(_: Afe) Error!void {
        try check(espz_sr_afe_disable_aec());
    }

    pub fn enableNs(_: Afe) Error!void {
        try check(espz_sr_afe_enable_ns());
    }

    pub fn disableNs(_: Afe) Error!void {
        try check(espz_sr_afe_disable_ns());
    }

    pub fn enableAgc(_: Afe) Error!void {
        try check(espz_sr_afe_enable_agc());
    }

    pub fn disableAgc(_: Afe) Error!void {
        try check(espz_sr_afe_disable_agc());
    }
};
