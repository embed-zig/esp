const std = @import("std");
const sdkconfig = @import("idf_sdkconfig");
const config_overrides = @import("../utils/config_overrides.zig");

pub const module_name = "esp_psram";

pub const Config = struct {
    /// Kconfig key: `CONFIG_SPIRAM`.
    /// Controls whether spiram is enabled for the `esp_psram` module; this affects conditional compilation and runtime behavior in ESP-IDF.
    /// Default: `false`.
    spiram: bool = false,
};

pub const default: Config = .{};

pub fn withDefaultConfig(overrides: anytype) Config {
    return config_overrides.withDefaultConfig(Config, overrides);
}
pub fn appendModuleDoc(
    allocator: std.mem.Allocator,
    docs: *std.array_list.Managed(sdkconfig.ModuleDoc),
    cfg: Config,
) std.mem.Allocator.Error!void {
    const entries = try allocator.alloc(sdkconfig.Entry, 1);
    entries[0] = sdkconfig.Entry.flag("CONFIG_SPIRAM", cfg.spiram);

    try docs.append(.{
        .name = module_name,
        .entries = entries,
    });
}

test "appendModuleDoc emits CONFIG_SPIRAM entry" {
    var docs = std.array_list.Managed(sdkconfig.ModuleDoc).init(std.testing.allocator);
    defer docs.deinit();

    try appendModuleDoc(std.testing.allocator, &docs, .{});

    const module_docs = try docs.toOwnedSlice();
    defer sdkconfig.freeModuleDocs(std.testing.allocator, module_docs);

    try std.testing.expectEqual(@as(usize, 1), module_docs.len);
    try std.testing.expect(std.mem.eql(u8, module_docs[0].name, module_name));
    try std.testing.expectEqual(@as(usize, 1), module_docs[0].entries.len);
    try std.testing.expect(std.mem.eql(u8, module_docs[0].entries[0].key, "CONFIG_SPIRAM"));
}
