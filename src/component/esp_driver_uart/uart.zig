pub const EspError = i32;
pub const esp_ok: EspError = 0;
const esp_err_invalid_arg: EspError = 0x102;
const esp_err_invalid_state: EspError = 0x103;

pub const Error = error{
    EspIdfFailure,
    InvalidArgument,
    NotInitialized,
};

pub fn check(result: EspError) Error!void {
    if (result == esp_ok) return;
    if (result == esp_err_invalid_arg) return error.InvalidArgument;
    if (result == esp_err_invalid_state) return error.NotInitialized;
    return error.EspIdfFailure;
}

pub const Config = struct {
    port: i32 = 0,
    tx_pin: i32 = 1,
    rx_pin: i32 = 3,
    baud_rate: u32 = 115200,
    rx_buffer_size: usize = 1024,
    tx_buffer_size: usize = 0,
};

extern fn espz_uart_init(
    port: i32,
    tx_pin: i32,
    rx_pin: i32,
    baud_rate: u32,
    rx_buffer_size: usize,
    tx_buffer_size: usize,
) EspError;
extern fn espz_uart_deinit(port: i32) EspError;
extern fn espz_uart_read(port: i32, out: [*]u8, len: usize, timeout_ms: u32, out_read_len: *i32) EspError;
extern fn espz_uart_write(port: i32, data: [*]const u8, len: usize, timeout_ms: u32, out_written_len: *i32) EspError;
extern fn espz_uart_buffered_len(port: i32, out_len: *usize) EspError;

pub fn init(cfg: Config) Error!void {
    try check(espz_uart_init(
        cfg.port,
        cfg.tx_pin,
        cfg.rx_pin,
        cfg.baud_rate,
        cfg.rx_buffer_size,
        cfg.tx_buffer_size,
    ));
}

pub fn deinit(port: i32) Error!void {
    try check(espz_uart_deinit(port));
}

pub fn read(port: i32, out: []u8, timeout_ms: u32) Error!usize {
    if (out.len == 0) return 0;
    var n: i32 = 0;
    try check(espz_uart_read(port, out.ptr, out.len, timeout_ms, &n));
    if (n <= 0) return 0;
    return @intCast(n);
}

pub fn write(port: i32, data: []const u8, timeout_ms: u32) Error!usize {
    if (data.len == 0) return 0;
    var n: i32 = 0;
    try check(espz_uart_write(port, data.ptr, data.len, timeout_ms, &n));
    if (n <= 0) return 0;
    return @intCast(n);
}

pub fn bufferedLen(port: i32) Error!usize {
    var len: usize = 0;
    try check(espz_uart_buffered_len(port, &len));
    return len;
}
