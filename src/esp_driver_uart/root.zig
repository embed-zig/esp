//! esp_driver_uart module: sdkconfig bindings + UART runtime API.

pub const config = @import("config.zig");
pub const uart = @import("uart.zig");
pub const Config = uart.Config;
pub const init = uart.init;
pub const deinit = uart.deinit;
pub const read = uart.read;
pub const write = uart.write;
pub const bufferedLen = uart.bufferedLen;

pub const module_name = "esp_driver_uart";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{ "driver", "esp_driver_uart" };
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
};
