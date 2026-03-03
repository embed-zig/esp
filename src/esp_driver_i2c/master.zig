pub const EspError = i32;
pub const esp_ok: EspError = 0;

pub const Error = error{ EspIdfFailure, InvalidArgument };

pub fn check(result: EspError) Error!void {
    if (result != esp_ok) return error.EspIdfFailure;
}

extern fn espz_i2c_master_init(port: i32, sda: i32, scl: i32, freq: u32) EspError;
extern fn espz_i2c_master_write_to_device(port: i32, addr: u8, data: [*]const u8, len: usize, timeout_ms: u32) EspError;
extern fn espz_i2c_master_write_read_device(port: i32, addr: u8, wd: [*]const u8, wlen: usize, rd: [*]u8, rlen: usize, timeout_ms: u32) EspError;

pub fn masterInit(port: i32, sda: i32, scl: i32, freq: u32) Error!void {
    try check(espz_i2c_master_init(port, sda, scl, freq));
}

pub fn masterWrite(port: i32, addr: u8, data: []const u8, timeout_ms: u32) Error!void {
    try check(espz_i2c_master_write_to_device(port, addr, data.ptr, data.len, timeout_ms));
}

pub fn masterWriteRead(port: i32, addr: u8, write_data: []const u8, read_data: []u8, timeout_ms: u32) Error!void {
    try check(espz_i2c_master_write_read_device(port, addr, write_data.ptr, write_data.len, read_data.ptr, read_data.len, timeout_ms));
}
