const std = @import("std");
const panel = @import("panel.zig");

pub const EspError = panel.EspError;
pub const Error = panel.Error;

extern fn espz_lcd_spi_bus_init(
    host_id: i32,
    sclk_io_num: i32,
    mosi_io_num: i32,
    miso_io_num: i32,
    max_transfer_bytes: usize,
    dma_channel: i32,
) EspError;
extern fn espz_lcd_spi_bus_deinit(host_id: i32) EspError;

extern fn espz_lcd_new_panel_io_spi(
    host_id: i32,
    cs_io_num: i32,
    dc_io_num: i32,
    pclk_hz: u32,
    spi_mode: u8,
    cmd_bits: u8,
    param_bits: u8,
    trans_queue_depth: u32,
    out_handle: *?*anyopaque,
) EspError;
extern fn espz_lcd_panel_io_del(io_handle: *anyopaque) EspError;
extern fn espz_lcd_panel_io_tx_param(
    io_handle: *anyopaque,
    cmd: u32,
    params: ?*const anyopaque,
    params_size: usize,
) EspError;
extern fn espz_lcd_panel_io_tx_color(
    io_handle: *anyopaque,
    cmd: u32,
    colors: ?*const anyopaque,
    color_size: usize,
) EspError;
extern fn espz_lcd_panel_io_rx_param(
    io_handle: *anyopaque,
    cmd: u32,
    out_params: ?*anyopaque,
    out_size: usize,
) EspError;

pub const Bus = struct {
    host_id: i32,
    active: bool,

    pub const Config = struct {
        host_id: i32,
        sclk_io_num: i32,
        mosi_io_num: i32,
        miso_io_num: i32 = -1,
        max_transfer_bytes: usize,
        dma_channel: i32 = -1,
    };

    pub fn init(cfg: Config) Error!Bus {
        if (cfg.max_transfer_bytes == 0) return error.InvalidArgument;
        try panel.check(espz_lcd_spi_bus_init(
            cfg.host_id,
            cfg.sclk_io_num,
            cfg.mosi_io_num,
            cfg.miso_io_num,
            cfg.max_transfer_bytes,
            cfg.dma_channel,
        ));

        return .{
            .host_id = cfg.host_id,
            .active = true,
        };
    }

    pub fn deinit(self: *Bus) Error!void {
        if (!self.active) return error.InvalidHandle;
        try panel.check(espz_lcd_spi_bus_deinit(self.host_id));
        self.active = false;
    }
};

pub const PanelIo = struct {
    handle: ?*anyopaque,

    pub const Config = struct {
        cs_io_num: i32 = -1,
        dc_io_num: i32,
        pclk_hz: u32,
        spi_mode: u8 = 0,
        cmd_bits: u8 = 8,
        param_bits: u8 = 8,
        trans_queue_depth: u32 = 10,
    };

    pub fn init(bus: *const Bus, cfg: Config) Error!PanelIo {
        if (!bus.active) return error.InvalidHandle;
        if (cfg.pclk_hz == 0) return error.InvalidArgument;

        var handle: ?*anyopaque = null;
        try panel.check(espz_lcd_new_panel_io_spi(
            bus.host_id,
            cfg.cs_io_num,
            cfg.dc_io_num,
            cfg.pclk_hz,
            cfg.spi_mode,
            cfg.cmd_bits,
            cfg.param_bits,
            cfg.trans_queue_depth,
            &handle,
        ));

        if (handle == null) return error.InvalidHandle;
        return .{ .handle = handle };
    }

    pub fn deinit(self: *PanelIo) Error!void {
        const handle = try self.raw();
        try panel.check(espz_lcd_panel_io_del(handle));
        self.handle = null;
    }

    pub fn raw(self: *const PanelIo) Error!*anyopaque {
        return self.handle orelse error.InvalidHandle;
    }

    pub fn txParam(self: *PanelIo, cmd: u32, params: ?[]const u8) Error!void {
        const handle = try self.raw();
        const ptr = if (params) |slice| @as(?*const anyopaque, if (slice.len == 0) null else @ptrCast(slice.ptr)) else null;
        const size = if (params) |slice| slice.len else 0;
        try panel.check(espz_lcd_panel_io_tx_param(handle, cmd, ptr, size));
    }

    pub fn txColor(self: *PanelIo, cmd: u32, color: []const u8) Error!void {
        const handle = try self.raw();
        if (color.len == 0) return error.InvalidArgument;
        try panel.check(espz_lcd_panel_io_tx_color(handle, cmd, @ptrCast(color.ptr), color.len));
    }

    pub fn rxParam(self: *PanelIo, cmd: u32, out: []u8) Error!void {
        const handle = try self.raw();
        if (out.len == 0) return error.InvalidArgument;
        try panel.check(espz_lcd_panel_io_rx_param(handle, cmd, @ptrCast(out.ptr), out.len));
    }
};

test "bus init validates transfer size" {
    try std.testing.expectError(error.InvalidArgument, Bus.init(.{
        .host_id = 2,
        .sclk_io_num = 41,
        .mosi_io_num = 40,
        .max_transfer_bytes = 0,
    }));
}

test "panel io raw rejects null" {
    const io = PanelIo{ .handle = null };
    try std.testing.expectError(error.InvalidHandle, io.raw());
}

test "txColor and rxParam validate buffer" {
    var io = PanelIo{ .handle = @ptrFromInt(1) };
    try std.testing.expectError(error.InvalidArgument, io.txColor(0x2C, &.{}));

    var out: [0]u8 = .{};
    try std.testing.expectError(error.InvalidArgument, io.rxParam(0x09, &out));
}
