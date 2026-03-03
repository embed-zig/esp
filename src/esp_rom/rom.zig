pub extern fn esp_rom_printf(format: [*:0]const u8, ...) c_int;

pub fn printf(comptime format: [*:0]const u8, args: anytype) void {
    _ = @call(.auto, esp_rom_printf, .{format} ++ args);
}
