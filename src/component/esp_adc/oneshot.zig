pub const EspError = i32;
pub const esp_ok: EspError = 0;

pub const Error = error{ EspIdfFailure, InvalidArgument };

pub fn check(result: EspError) Error!void {
    if (result != esp_ok) return error.EspIdfFailure;
}

extern fn espz_adc_oneshot_init(unit: i32, channel: i32, out: *?*anyopaque) EspError;
extern fn espz_adc_oneshot_read(handle: *anyopaque, channel: i32, out_raw: *i32) EspError;
extern fn espz_adc_oneshot_deinit(handle: *anyopaque) EspError;

pub const Oneshot = struct {
    handle: *anyopaque,
    channel: i32,

    pub fn init(unit: i32, channel: i32) Error!Oneshot {
        var handle: ?*anyopaque = null;
        try check(espz_adc_oneshot_init(unit, channel, &handle));
        return .{ .handle = handle orelse return error.EspIdfFailure, .channel = channel };
    }

    pub fn read(self: *const Oneshot) Error!i32 {
        var raw: i32 = 0;
        try check(espz_adc_oneshot_read(self.handle, self.channel, &raw));
        return raw;
    }

    pub fn deinit(self: *Oneshot) Error!void {
        try check(espz_adc_oneshot_deinit(self.handle));
        self.handle = undefined;
    }
};
