const lcd_spi = @import("../component/esp_lcd/spi.zig");
const lcd_panel = @import("../component/esp_lcd/panel.zig");
const lcd_driver = @import("../component/esp_lcd/driver.zig");
const hal_display = @import("embed").hal.display;

pub const Color565 = hal_display.Color565;
pub const Error = hal_display.Error;
pub const rgb565 = hal_display.rgb565;

pub const Driver = struct {
    bus: lcd_spi.Bus,
    io: lcd_spi.PanelIo,
    panel: lcd_panel.Panel,
    width_px: u16,
    height_px: u16,

    pub const PanelKind = enum {
        st7789,
        ili9341,
    };

    pub const DataEndian = enum(u32) {
        big = 0,
        little = 1,
    };

    pub const Config = struct {
        panel: PanelKind = .st7789,
        width: u16 = 240,
        height: u16 = 240,

        host_id: i32 = 2,
        sclk: i32 = 18,
        mosi: i32 = 23,
        miso: i32 = -1,
        cs: i32 = 5,
        dc: i32 = 21,
        reset: i32 = -1,

        pclk_hz: u32 = 20_000_000,
        spi_mode: u8 = 0,
        max_transfer_bytes: usize = 4096,
        dma_channel: i32 = 3,
        cmd_bits: u8 = 8,
        param_bits: u8 = 8,
        trans_queue_depth: u32 = 10,

        invert_color: bool = false,
        swap_xy: bool = false,
        mirror_x: bool = false,
        mirror_y: bool = false,
        data_endian: DataEndian = .big,
        x_gap: i32 = 0,
        y_gap: i32 = 0,

        /// Called after panel.reset() but before panel.init().
        /// Use for board-specific setup such as GPIO expander CS control.
        pre_init_hook: ?*const fn () void = null,
    };

    pub fn init(cfg: Config) Error!Driver {
        if (cfg.width == 0 or cfg.height == 0) return error.DisplayError;

        var bus = lcd_spi.Bus.init(.{
            .host_id = cfg.host_id,
            .sclk_io_num = cfg.sclk,
            .mosi_io_num = cfg.mosi,
            .miso_io_num = cfg.miso,
            .max_transfer_bytes = cfg.max_transfer_bytes,
            .dma_channel = cfg.dma_channel,
        }) catch return error.DisplayError;
        errdefer bus.deinit() catch {};

        var io = lcd_spi.PanelIo.init(&bus, .{
            .cs_io_num = cfg.cs,
            .dc_io_num = cfg.dc,
            .pclk_hz = cfg.pclk_hz,
            .spi_mode = cfg.spi_mode,
            .cmd_bits = cfg.cmd_bits,
            .param_bits = cfg.param_bits,
            .trans_queue_depth = cfg.trans_queue_depth,
        }) catch return error.DisplayError;
        errdefer io.deinit() catch {};

        var panel = switch (cfg.panel) {
            .st7789 => lcd_driver.create(lcd_driver.st7789, &io, .{
                .reset_gpio_num = cfg.reset,
                .data_endian = @intFromEnum(cfg.data_endian),
                .bits_per_pixel = 16,
            }) catch return error.DisplayError,
            .ili9341 => lcd_driver.create(lcd_driver.ili9341, &io, .{
                .reset_gpio_num = cfg.reset,
                .data_endian = @intFromEnum(cfg.data_endian),
                .bits_per_pixel = 16,
            }) catch return error.DisplayError,
        };
        errdefer panel.deinit() catch {};

        panel.reset() catch return error.DisplayError;
        if (cfg.pre_init_hook) |hook| hook();
        panel.init() catch return error.DisplayError;

        if (cfg.invert_color) panel.invertColor(true) catch return error.DisplayError;
        if (cfg.swap_xy) panel.swapXY(true) catch return error.DisplayError;
        if (cfg.mirror_x or cfg.mirror_y) panel.mirror(cfg.mirror_x, cfg.mirror_y) catch return error.DisplayError;
        if (cfg.x_gap != 0 or cfg.y_gap != 0) panel.setGap(cfg.x_gap, cfg.y_gap) catch return error.DisplayError;

        panel.setDisplayEnabled(true) catch return error.DisplayError;

        return .{
            .bus = bus,
            .io = io,
            .panel = panel,
            .width_px = cfg.width,
            .height_px = cfg.height,
        };
    }

    pub fn deinit(self: *Driver) void {
        self.panel.deinit() catch {};
        self.io.deinit() catch {};
        self.bus.deinit() catch {};
    }

    pub fn width(self: *const Driver) u16 {
        return self.width_px;
    }

    pub fn height(self: *const Driver) u16 {
        return self.height_px;
    }

    pub fn setDisplayEnabled(self: *Driver, enabled: bool) Error!void {
        self.panel.setDisplayEnabled(enabled) catch return error.DisplayError;
    }

    pub fn sleep(self: *Driver, enabled: bool) Error!void {
        self.panel.sleep(enabled) catch return error.DisplayError;
    }

    pub fn drawBitmap(self: *Driver, x: u16, y: u16, w: u16, h: u16, data: []const Color565) Error!void {
        if (w == 0 or h == 0) return;
        self.panel.drawBitmap(
            @intCast(x),
            @intCast(y),
            @intCast(@as(u32, x) + w),
            @intCast(@as(u32, y) + h),
            @ptrCast(data.ptr),
        ) catch return error.DisplayError;
    }
};
