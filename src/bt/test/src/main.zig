const bt = @import("bt");

comptime {
    _ = bt.VHci;
    _ = bt.controller;
}

export fn zig_esp_main() callconv(.c) void {}
