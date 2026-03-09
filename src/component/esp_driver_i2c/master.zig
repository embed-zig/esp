const esp_error = @import("../esp_error.zig");
pub const EspError = esp_error.EspError;
pub const Error = esp_error.Error;
const check = esp_error.check;

extern fn espz_i2c_master_init(port: i32, sda: i32, scl: i32, freq: u32) EspError;
extern fn espz_i2c_master_write_to_device(port: i32, addr: u8, data: [*]const u8, len: usize, timeout_ms: u32) EspError;
extern fn espz_i2c_master_write_read_device(port: i32, addr: u8, wd: [*]const u8, wlen: usize, rd: [*]u8, rlen: usize, timeout_ms: u32) EspError;

pub const Config = struct {
    port: i32 = 0,
    sda: i32,
    scl: i32,
    freq_hz: u32 = 100_000,
};

pub const I2cMaster = struct {
    port: i32,

    pub fn init(cfg: Config) Error!I2cMaster {
        try check(espz_i2c_master_init(cfg.port, cfg.sda, cfg.scl, cfg.freq_hz));
        return .{ .port = cfg.port };
    }

    pub fn write(self: I2cMaster, addr: u8, data: []const u8, timeout_ms: u32) Error!void {
        try check(espz_i2c_master_write_to_device(self.port, addr, data.ptr, data.len, timeout_ms));
    }

    pub fn writeRead(self: I2cMaster, addr: u8, write_data: []const u8, read_data: []u8, timeout_ms: u32) Error!void {
        try check(espz_i2c_master_write_read_device(self.port, addr, write_data.ptr, write_data.len, read_data.ptr, read_data.len, timeout_ms));
    }
};
