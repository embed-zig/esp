const esp = @import("esp");
const app_metadata = esp.component.app_metadata;

comptime {
    _ = app_metadata.ota;
    _ = app_metadata.ota.Handle;
    _ = app_metadata.ota.AppState;
    _ = app_metadata.ota.Error;
    _ = app_metadata.ota.begin;
    _ = app_metadata.ota.write;
    _ = app_metadata.ota.end;
}

export fn zig_esp_main() callconv(.c) void {}
