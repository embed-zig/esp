pub const config = @import("build_config").config;

pub const pins = .{
    .wifi = .{
        .ssid = @as([]const u8, "espz-test-ap"),
        .password = @as([]const u8, "espz1234"),
        .listen_interval = @as(u16, 3),
    },
};
