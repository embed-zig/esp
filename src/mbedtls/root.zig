//! mbedTLS module: sdkconfig bindings + crypto API.

pub const config = @import("config.zig");
pub const mbed_tls = @import("mbed_tls.zig");

pub const module_name = "mbedtls";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{ "mbedtls", "esp-tls" };
pub const embedded_files = .{
    .{
        .path = @as([]const u8, "c_helper.c"),
        .content = @embedFile("c_helper.c"),
    },
};
