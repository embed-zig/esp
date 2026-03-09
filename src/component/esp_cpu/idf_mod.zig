const EmbeddedFile = @import("../../idf/cmake/component.zig").EmbeddedFile;

pub const module_name = "esp_cpu";
pub const idf_requires = &.{"esp_hw_support"};
pub const embedded_files: []const EmbeddedFile = &.{};
