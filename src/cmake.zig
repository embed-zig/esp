pub const Entry = struct {
    root: type,
    sdkconfig_guard: ?[]const u8 = null,
};

pub const modules = [_]Entry{
    .{ .root = @import("esp_lcd/root.zig") },
    .{ .root = @import("esp_driver_i2c/root.zig") },
    .{ .root = @import("esp_driver_ledc/root.zig") },
    .{ .root = @import("esp_adc/root.zig") },
    .{ .root = @import("esp_wifi/root.zig") },
    .{ .root = @import("bt/root.zig"), .sdkconfig_guard = "CONFIG_BT_ENABLED" },
    .{ .root = @import("freertos/root.zig") },
    .{ .root = @import("esp_rom/root.zig") },
    .{ .root = @import("newlib/root.zig") },
    .{ .root = @import("nvs_flash/root.zig") },
    .{ .root = @import("heap/root.zig") },
};
