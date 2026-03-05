pub const config = @import("config.zig");
pub const i2s = @import("i2s.zig");

pub const Role = i2s.Role;
pub const BitsPerSample = i2s.BitsPerSample;
pub const SlotMode = i2s.SlotMode;
pub const ChannelMode = i2s.ChannelMode;
pub const RxConfig = i2s.RxConfig;
pub const TxConfig = i2s.TxConfig;
pub const DuplexConfig = i2s.DuplexConfig;
pub const I2sRx = i2s.I2sRx;
pub const I2sTx = i2s.I2sTx;
pub const I2sDuplex = i2s.I2sDuplex;
pub const Error = i2s.Error;

pub const module_name = "esp_driver_i2s";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{ "driver", "esp_driver_i2s" };
pub const embedded_files = .{
    .{ .path = @as([]const u8, "c_helper.c"), .content = @embedFile("c_helper.c") },
};
