pub const EspError = i32;
pub const esp_ok: EspError = 0;
pub const esp_fail: EspError = -1;
pub const esp_err_no_mem: EspError = 0x101;
pub const esp_err_invalid_arg: EspError = 0x102;
pub const esp_err_invalid_state: EspError = 0x103;
pub const esp_err_invalid_size: EspError = 0x104;
pub const esp_err_not_found: EspError = 0x105;
pub const esp_err_not_supported: EspError = 0x106;
pub const esp_err_timeout: EspError = 0x107;

pub const Error = error{
    Fail,
    NoMem,
    InvalidArg,
    InvalidState,
    InvalidSize,
    NotFound,
    NotSupported,
    Timeout,
};

pub fn check(rc: EspError) Error!void {
    if (rc == esp_ok) return;
    return switch (rc) {
        esp_fail => error.Fail,
        esp_err_no_mem => error.NoMem,
        esp_err_invalid_arg => error.InvalidArg,
        esp_err_invalid_state => error.InvalidState,
        esp_err_invalid_size => error.InvalidSize,
        esp_err_not_found => error.NotFound,
        esp_err_not_supported => error.NotSupported,
        esp_err_timeout => error.Timeout,
        else => error.Fail,
    };
}
