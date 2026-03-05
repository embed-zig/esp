pub const random = @import("random.zig");
pub const fill = random.fill;

pub const module_name = "esp_random";
pub const zig_root = "root.zig";
pub const idf_requires = [_][]const u8{"esp_hw_support"};
pub const embedded_files = .{};
