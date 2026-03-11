const std = @import("std");
const idf = @import("idf");
const schema = idf.sdkconfig;
const modules = idf.sdkconfig_components;
const partition = idf.partition;
const profile = @import("app_sdkconfig_profile");

const Config = @TypeOf(profile.config);

comptime {
    ensureBoardField(Config);
    ensurePartitionTableField(Config);
}

pub fn collectModuleDocs(
    allocator: std.mem.Allocator,
    partition_csv_filename: []const u8,
) ![]schema.ModuleDoc {
    const table = partitionTable();
    validatePartitionTable(table);

    var docs = std.array_list.Managed(schema.ModuleDoc).init(allocator);
    errdefer docs.deinit();

    inline for (@typeInfo(Config).@"struct".fields) |field| {
        const val = @field(profile.config, field.name);
        const ValType = @TypeOf(val);
        if (@hasDecl(ValType, "appendModuleDoc")) {
            if (comptime std.mem.eql(u8, field.name, "core")) {
                const core_cfg = try effectiveCoreConfig(allocator, partition_csv_filename, table.offset);
                try ValType.appendModuleDoc(allocator, &docs, core_cfg);
            } else if (comptime std.mem.eql(u8, field.name, "partition_table_cfg")) {
                const partition_cfg = try effectivePartitionTableConfig(allocator, partition_csv_filename, table.offset);
                try ValType.appendModuleDoc(allocator, &docs, partition_cfg);
            } else {
                try ValType.appendModuleDoc(allocator, &docs, val);
            }
        }
    }

    try appendBoardDoc(allocator, &docs, profile.config.board);

    return docs.toOwnedSlice();
}

pub fn renderPartitionCsv(allocator: std.mem.Allocator) ![]u8 {
    const table = partitionTable();
    validatePartitionTable(table);
    const resolved = try partition.resolveEntriesAlloc(allocator, table);
    defer allocator.free(resolved);
    return partition.renderCsv(allocator, resolved);
}

fn appendBoardDoc(
    allocator: std.mem.Allocator,
    docs: *std.array_list.Managed(schema.ModuleDoc),
    board_cfg: anytype,
) std.mem.Allocator.Error!void {
    const entries = try allocator.alloc(schema.Entry, 4);
    entries[0] = schema.Entry.flag(board_cfg.target_arch_config_flag, true);
    entries[1] = schema.Entry.str("CONFIG_IDF_TARGET_ARCH", board_cfg.target_arch);
    entries[2] = schema.Entry.str("CONFIG_IDF_TARGET", board_cfg.chip);
    entries[3] = schema.Entry.flag(board_cfg.target_config_flag, true);

    try docs.append(.{
        .name = board_cfg.name,
        .entries = entries,
    });
}

fn partitionTable() partition.Table {
    return profile.config.partition_table;
}

fn effectiveCoreConfig(
    allocator: std.mem.Allocator,
    partition_csv_filename: []const u8,
    partition_offset: u32,
) !modules.esp_system_config.Config {
    var core_cfg: modules.esp_system_config.Config = profile.config.core;
    core_cfg.partition_table_custom_filename = partition_csv_filename;
    core_cfg.partition_table_offset_hex = try std.fmt.allocPrint(allocator, "0x{x}", .{partition_offset});
    return core_cfg;
}

fn effectivePartitionTableConfig(
    allocator: std.mem.Allocator,
    partition_csv_filename: []const u8,
    partition_offset: u32,
) !modules.partition_table_config.Config {
    var partition_cfg: modules.partition_table_config.Config = profile.config.partition_table_cfg;
    partition_cfg.partition_table_custom = true;
    partition_cfg.partition_table_custom_filename = partition_csv_filename;
    partition_cfg.partition_table_filename = partition_csv_filename;
    partition_cfg.partition_table_offset = try std.fmt.allocPrint(allocator, "0x{x}", .{partition_offset});
    return partition_cfg;
}

fn validatePartitionTable(table: partition.Table) void {
    partition.validateEntries(table.entries) catch {
        @panic("partition table must include an app partition (factory or ota_0)");
    };
}

fn ensurePartitionTableField(comptime ConfigType: type) void {
    if (!@hasField(ConfigType, "partition_table")) {
        @compileError("board config must define partition_table field");
    }

    if (@FieldType(ConfigType, "partition_table") != partition.Table) {
        @compileError(std.fmt.comptimePrint(
            "board config field 'partition_table' must be {s}",
            .{@typeName(partition.Table)},
        ));
    }
}

fn ensureBoardField(comptime ConfigType: type) void {
    if (!@hasField(ConfigType, "board")) {
        @compileError("board config must define board field");
    }

    const board_type = @FieldType(ConfigType, "board");
    ensureFieldType(board_type, "name", []const u8);
    ensureFieldType(board_type, "chip", []const u8);
    ensureFieldType(board_type, "target_arch", []const u8);
    ensureFieldType(board_type, "target_arch_config_flag", []const u8);
    ensureFieldType(board_type, "target_config_flag", []const u8);

    if (@hasField(board_type, "psram_enabled")) {
        @compileError(
            "board.psram_enabled is deprecated; configure CONFIG_SPIRAM via esp_psram module config",
        );
    }
}

fn ensureFieldType(comptime Container: type, comptime field_name: []const u8, comptime Expected: type) void {
    if (!@hasField(Container, field_name)) {
        @compileError(std.fmt.comptimePrint(
            "board config field 'board' is missing required sub-field '{s}'",
            .{field_name},
        ));
    }

    const field_type = @FieldType(Container, field_name);
    if (field_type != Expected) {
        @compileError(std.fmt.comptimePrint(
            "board.{s} type mismatch: expected {s}, found {s}",
            .{ field_name, @typeName(Expected), @typeName(field_type) },
        ));
    }
}
