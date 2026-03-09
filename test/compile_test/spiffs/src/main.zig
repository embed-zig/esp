const esp = @import("esp");
const spiffs = esp.component.spiffs.spiffs;
comptime {
    _ = spiffs.mount;
    _ = spiffs.unmount;
    _ = spiffs.info;
    _ = spiffs.Info;
    _ = spiffs.Error;
}
export fn zig_esp_main() callconv(.c) void {}
