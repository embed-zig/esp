const std = @import("std");

pub const EspError = i32;
pub const esp_ok: EspError = 0;

pub const Error = error{
    EspIdfFailure,
    InvalidHandle,
    InvalidArgument,
};

extern fn espz_lcd_panel_reset(panel: *anyopaque) EspError;
extern fn espz_lcd_panel_init(panel: *anyopaque) EspError;
extern fn espz_lcd_panel_del(panel: *anyopaque) EspError;
extern fn espz_lcd_panel_draw_bitmap(
    panel: *anyopaque,
    x_start: i32,
    y_start: i32,
    x_end: i32,
    y_end: i32,
    color_data: ?*const anyopaque,
) EspError;
extern fn espz_lcd_panel_mirror(panel: *anyopaque, mirror_x: bool, mirror_y: bool) EspError;
extern fn espz_lcd_panel_swap_xy(panel: *anyopaque, enabled: bool) EspError;
extern fn espz_lcd_panel_invert_color(panel: *anyopaque, enabled: bool) EspError;
extern fn espz_lcd_panel_set_gap(panel: *anyopaque, x_gap: i32, y_gap: i32) EspError;
extern fn espz_lcd_panel_disp_on_off(panel: *anyopaque, enabled: bool) EspError;
extern fn espz_lcd_panel_disp_sleep(panel: *anyopaque, enabled: bool) EspError;

pub fn check(result: EspError) Error!void {
    if (result != esp_ok) return error.EspIdfFailure;
}

pub const Panel = struct {
    handle: ?*anyopaque,

    pub fn fromHandle(handle: ?*anyopaque) Error!Panel {
        if (handle == null) return error.InvalidHandle;
        return .{ .handle = handle };
    }

    pub fn raw(self: *const Panel) Error!*anyopaque {
        return self.requireHandle();
    }

    pub fn reset(self: *Panel) Error!void {
        const handle = try self.requireHandle();
        try check(espz_lcd_panel_reset(handle));
    }

    pub fn init(self: *Panel) Error!void {
        const handle = try self.requireHandle();
        try check(espz_lcd_panel_init(handle));
    }

    pub fn deinit(self: *Panel) Error!void {
        const handle = try self.requireHandle();
        try check(espz_lcd_panel_del(handle));
        self.handle = null;
    }

    pub fn drawBitmap(
        self: *Panel,
        x_start: i32,
        y_start: i32,
        x_end: i32,
        y_end: i32,
        pixels: ?*const anyopaque,
    ) Error!void {
        const handle = try self.requireHandle();
        if (x_end <= x_start or y_end <= y_start) return error.InvalidArgument;
        try check(espz_lcd_panel_draw_bitmap(handle, x_start, y_start, x_end, y_end, pixels));
    }

    pub fn mirror(self: *Panel, mirror_x: bool, mirror_y: bool) Error!void {
        const handle = try self.requireHandle();
        try check(espz_lcd_panel_mirror(handle, mirror_x, mirror_y));
    }

    pub fn swapXY(self: *Panel, enabled: bool) Error!void {
        const handle = try self.requireHandle();
        try check(espz_lcd_panel_swap_xy(handle, enabled));
    }

    pub fn invertColor(self: *Panel, enabled: bool) Error!void {
        const handle = try self.requireHandle();
        try check(espz_lcd_panel_invert_color(handle, enabled));
    }

    pub fn setGap(self: *Panel, x_gap: i32, y_gap: i32) Error!void {
        const handle = try self.requireHandle();
        try check(espz_lcd_panel_set_gap(handle, x_gap, y_gap));
    }

    pub fn setDisplayEnabled(self: *Panel, enabled: bool) Error!void {
        const handle = try self.requireHandle();
        try check(espz_lcd_panel_disp_on_off(handle, enabled));
    }

    pub fn sleep(self: *Panel, enabled: bool) Error!void {
        const handle = try self.requireHandle();
        try check(espz_lcd_panel_disp_sleep(handle, enabled));
    }

    fn requireHandle(self: *const Panel) Error!*anyopaque {
        return self.handle orelse error.InvalidHandle;
    }
};

test "check maps ESP_OK and non-zero result" {
    try check(esp_ok);
    try std.testing.expectError(error.EspIdfFailure, check(-1));
}

test "fromHandle rejects null" {
    try std.testing.expectError(error.InvalidHandle, Panel.fromHandle(null));
}

test "drawBitmap validates range before FFI" {
    var panel = try Panel.fromHandle(@ptrFromInt(1));
    try std.testing.expectError(error.InvalidArgument, panel.drawBitmap(10, 10, 10, 20, null));
    try std.testing.expectError(error.InvalidArgument, panel.drawBitmap(10, 10, 20, 10, null));
}

test "deinit on invalid handle returns error" {
    var panel = Panel{ .handle = null };
    try std.testing.expectError(error.InvalidHandle, panel.deinit());
}
