pub const Error = error{EspFail};

extern fn nvs_flash_init() i32;
extern fn nvs_flash_deinit() i32;
extern fn nvs_flash_erase() i32;

pub fn init() Error!void {
    if (nvs_flash_init() != 0) return error.EspFail;
}

pub fn deinit() Error!void {
    if (nvs_flash_deinit() != 0) return error.EspFail;
}

pub fn erase() Error!void {
    if (nvs_flash_erase() != 0) return error.EspFail;
}
