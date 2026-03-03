pub const PartitionType = enum {
    app,
    data,
};

pub const Partition = struct {
    name: []const u8,
    kind: PartitionType,
    subtype: []const u8,
    offset_hex: ?[]const u8 = null,
    size_hex: []const u8,
    flags: ?[]const u8 = null,
};

pub const Table = struct {
    offset_hex: []const u8,
    entries: []const Partition,
};
