const esp_wifi = @import("esp_wifi");
comptime {
    _ = esp_wifi.WiFi;
}
export fn zig_esp_main() callconv(.c) void {}
