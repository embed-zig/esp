const esp = @import("esp");
const newlib = esp.component.newlib;
comptime {
    _ = newlib.libc;
    _ = newlib.fs;
    _ = newlib.abort;
}
export fn zig_esp_main() callconv(.c) void {}
