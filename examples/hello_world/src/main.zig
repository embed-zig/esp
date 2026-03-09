const esp = @import("esp");
const esp_component = esp.component;
const rom = esp_component.esp_rom;
const freertos = esp_component.freertos;
const heap = esp_component.heap;

export fn zig_esp_main() callconv(.c) void {
    _ = rom.esp_rom_printf("hello world from pure zig\n");
    _ = rom.esp_rom_printf("heap: free=%u min_free=%u\n", heap.freeHeapSize(), heap.minimumFreeHeapSize());

    while (true) {
        _ = rom.esp_rom_printf("hello world heartbeat\n");
        freertos.delay(200);
    }
}
