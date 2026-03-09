const esp = @import("esp");
const bt = esp.component.bt;

comptime {
    _ = bt.VHci;
    _ = bt.controller;
}

export fn zig_esp_main() callconv(.c) void {}
