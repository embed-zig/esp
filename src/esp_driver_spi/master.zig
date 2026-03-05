const esp_error = @import("utils").esp_error;
pub const EspError = esp_error.EspError;
pub const Error = esp_error.Error;
const check = esp_error.check;

extern fn espz_spi_master_init(
    host_id: i32,
    mosi_io_num: i32,
    miso_io_num: i32,
    sclk_io_num: i32,
    cs_io_num: i32,
    clock_hz: u32,
    mode: u8,
) EspError;
extern fn espz_spi_master_deinit(host_id: i32) EspError;
extern fn espz_spi_master_write(host_id: i32, data: [*]const u8, len: usize, timeout_ms: u32) EspError;
extern fn espz_spi_master_transfer(host_id: i32, tx: [*]const u8, rx: [*]u8, len: usize, timeout_ms: u32) EspError;
extern fn espz_spi_master_read(host_id: i32, rx: [*]u8, len: usize, timeout_ms: u32) EspError;

pub const Config = struct {
    host_id: i32 = 2,
    mosi: i32,
    miso: i32 = -1,
    sclk: i32,
    cs: i32 = -1,
    clock_hz: u32 = 1_000_000,
    mode: u8 = 0,
};

pub const SpiMaster = struct {
    host_id: i32,

    pub fn init(cfg: Config) Error!SpiMaster {
        try check(espz_spi_master_init(cfg.host_id, cfg.mosi, cfg.miso, cfg.sclk, cfg.cs, cfg.clock_hz, cfg.mode));
        return .{ .host_id = cfg.host_id };
    }

    pub fn deinit(self: SpiMaster) Error!void {
        try check(espz_spi_master_deinit(self.host_id));
    }

    pub fn write(self: SpiMaster, data: []const u8) Error!void {
        if (data.len == 0) return;
        try check(espz_spi_master_write(self.host_id, data.ptr, data.len, 0));
    }

    pub fn transfer(self: SpiMaster, tx: []const u8, rx: []u8) Error!void {
        if (tx.len != rx.len) return error.InvalidArg;
        if (tx.len == 0) return;
        try check(espz_spi_master_transfer(self.host_id, tx.ptr, rx.ptr, tx.len, 0));
    }

    pub fn read(self: SpiMaster, rx: []u8) Error!void {
        if (rx.len == 0) return;
        try check(espz_spi_master_read(self.host_id, rx.ptr, rx.len, 0));
    }
};
