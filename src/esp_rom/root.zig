pub const rom = @import("rom.zig");
pub const esp_rom_printf = rom.esp_rom_printf;
pub const printf = rom.printf;

pub const module_name = "esp_rom";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"esp_rom"};
pub const embedded_files = .{};
