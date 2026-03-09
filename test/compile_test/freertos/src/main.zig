const esp = @import("esp");
const freertos = esp.component.freertos;
comptime {
    _ = freertos.delay;
    _ = freertos.create;
    _ = freertos.delete;
    _ = freertos.msToTicks;
    _ = freertos.TickType;
    _ = freertos.TaskHandle;
    _ = freertos.queue;
}
export fn zig_esp_main() callconv(.c) void {}
