const esp = @import("esp");
const esp_rom = esp.component.esp_rom;
comptime {
    _ = esp_rom.esp_rom_printf;
    _ = esp_rom.printf;
}
export fn zig_esp_main() callconv(.c) void {}
