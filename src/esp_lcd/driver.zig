const std = @import("std");
const panel = @import("panel.zig");
const spi = @import("spi.zig");

pub const Error = panel.Error;
pub const Panel = panel.Panel;

extern fn espz_lcd_new_panel_st7789(
    io_handle: *anyopaque,
    reset_gpio_num: i32,
    rgb_element_order: u32,
    bits_per_pixel: u8,
    out_panel_handle: *?*anyopaque,
) panel.EspError;
extern fn espz_lcd_new_panel_ili9341(
    io_handle: *anyopaque,
    reset_gpio_num: i32,
    rgb_element_order: u32,
    bits_per_pixel: u8,
    out_panel_handle: *?*anyopaque,
) panel.EspError;

pub fn create(comptime Driver: type, io: *spi.PanelIo, cfg: Driver.Config) Error!Panel {
    return Driver.create(io, cfg);
}

pub const st7789 = struct {
    pub const Config = struct {
        reset_gpio_num: i32 = -1,
        rgb_element_order: u32 = 0,
        bits_per_pixel: u8 = 16,
    };

    pub fn create(io: *spi.PanelIo, cfg: Config) Error!Panel {
        const io_handle = try io.raw();
        if (cfg.bits_per_pixel == 0) return error.InvalidArgument;

        var panel_handle: ?*anyopaque = null;
        try panel.check(espz_lcd_new_panel_st7789(
            io_handle,
            cfg.reset_gpio_num,
            cfg.rgb_element_order,
            cfg.bits_per_pixel,
            &panel_handle,
        ));
        return panel.Panel.fromHandle(panel_handle);
    }
};

pub const ili9341 = struct {
    pub const Config = struct {
        reset_gpio_num: i32 = -1,
        rgb_element_order: u32 = 0,
        bits_per_pixel: u8 = 16,
    };

    pub fn create(io: *spi.PanelIo, cfg: Config) Error!Panel {
        const io_handle = try io.raw();
        if (cfg.bits_per_pixel == 0) return error.InvalidArgument;

        var panel_handle: ?*anyopaque = null;
        try panel.check(espz_lcd_new_panel_ili9341(
            io_handle,
            cfg.reset_gpio_num,
            cfg.rgb_element_order,
            cfg.bits_per_pixel,
            &panel_handle,
        ));
        return panel.Panel.fromHandle(panel_handle);
    }
};

test "generic create dispatches to driver implementation" {
    const FakeDriver = struct {
        pub const Config = struct {
            value: u8,
        };

        pub var called: bool = false;

        pub fn create(io: *spi.PanelIo, cfg: Config) Error!Panel {
            _ = io;
            _ = cfg;
            called = true;
            return panel.Panel.fromHandle(@ptrFromInt(1));
        }
    };

    var io = spi.PanelIo{ .handle = @ptrFromInt(1) };
    _ = try create(FakeDriver, &io, .{ .value = 1 });
    try std.testing.expect(FakeDriver.called);
}
