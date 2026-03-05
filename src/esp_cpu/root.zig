pub const cpu = @import("cpu.zig");
pub const getCoreCount = cpu.getCoreCount;

pub const module_name = "esp_cpu";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"esp_hw_support"};
pub const embedded_files = .{};
