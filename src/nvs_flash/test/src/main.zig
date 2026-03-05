const nvs_flash = @import("nvs_flash");
comptime {
    _ = nvs_flash.init;
    _ = nvs_flash.deinit;
    _ = nvs_flash.erase;
    _ = nvs_flash.Namespace;
}
export fn zig_esp_main() callconv(.c) void {}
