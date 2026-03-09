const esp = @import("esp");
const esp_wifi = esp.component.esp_wifi;
comptime {
    _ = esp_wifi.WiFi;
}
export fn zig_esp_main() callconv(.c) void {}
