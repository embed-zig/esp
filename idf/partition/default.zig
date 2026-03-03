const schema = @import("schema.zig");

const entries = [_]schema.Partition{
    .{ .name = "nvs", .kind = .data, .subtype = "nvs", .offset_hex = "0x9000", .size_hex = "0x6000" },
    .{ .name = "phy_init", .kind = .data, .subtype = "phy", .offset_hex = "0xf000", .size_hex = "0x1000" },
    .{ .name = "factory", .kind = .app, .subtype = "factory", .offset_hex = "0x10000", .size_hex = "1M" },
};

pub const table: schema.Table = .{
    .offset_hex = "0x8000",
    .entries = &entries,
};
