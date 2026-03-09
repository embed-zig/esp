pub const Error = error{EspFail};

pub const Mode = enum(u32) {
    idle = 0,
    ble = 1,
    classic_bt = 2,
    btdm = 3,
};

extern fn espz_bt_controller_init_default() i32;
extern fn espz_bt_controller_enable(mode: u32) i32;
extern fn espz_bt_controller_disable() i32;
extern fn espz_bt_controller_deinit() i32;

/// Initialize BT controller with default config.
pub fn init() Error!void {
    if (espz_bt_controller_init_default() != 0) return error.EspFail;
}

/// Enable BT controller in the given mode.
pub fn enable(mode: Mode) Error!void {
    if (espz_bt_controller_enable(@intFromEnum(mode)) != 0) return error.EspFail;
}

/// Disable BT controller.
pub fn disable() Error!void {
    if (espz_bt_controller_disable() != 0) return error.EspFail;
}

/// De-initialize BT controller and free resources.
pub fn deinit() Error!void {
    if (espz_bt_controller_deinit() != 0) return error.EspFail;
}
