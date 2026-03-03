const std = @import("std");
const modules = @import("sdkconfig_modules");
const partition = @import("idf_partition");
const profile = @import("app_sdkconfig_profile");

pub const schema = modules.schema;

const Config = @TypeOf(profile.config);

comptime {
    modules.ensureAllModuleConfig(Config);
    ensureBoardField(Config);
    ensurePartitionTableField(Config);
}

pub fn collectModuleDocs(
    allocator: std.mem.Allocator,
    partition_csv_filename: []const u8,
) ![]schema.ModuleDoc {
    const table = partitionTable();
    validatePartitionTable(table);
    const core_cfg = effectiveCoreConfig(partition_csv_filename, table.offset_hex);
    const partition_cfg = effectivePartitionTableConfig(partition_csv_filename, table.offset_hex);

    var docs = std.array_list.Managed(schema.ModuleDoc).init(allocator);
    errdefer docs.deinit();

    try modules.esp_system_config.appendModuleDoc(allocator, &docs, core_cfg);
    try modules.partition_table_config.appendModuleDoc(allocator, &docs, partition_cfg);
    try modules.appendAllModuleDocsSkippingFields(
        Config,
        &.{ "core", "partition_table_cfg" },
        allocator,
        &docs,
        profile.config,
    );
    try appendBoardDoc(allocator, &docs, profile.config.board);

    return docs.toOwnedSlice();
}

pub fn renderPartitionCsv(allocator: std.mem.Allocator) ![]u8 {
    const table = partitionTable();
    validatePartitionTable(table);
    return partition.renderCsv(allocator, table.entries);
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
    partition_csv_filename: []const u8,
    partition_offset_hex: []const u8,
) modules.esp_system_config.Config {
    var core_cfg: modules.esp_system_config.Config = profile.config.core;
    core_cfg.partition_table_custom_filename = partition_csv_filename;
    core_cfg.partition_table_offset_hex = partition_offset_hex;
    return core_cfg;
}

fn effectivePartitionTableConfig(
    partition_csv_filename: []const u8,
    partition_offset_hex: []const u8,
) modules.partition_table_config.Config {
    var partition_cfg: modules.partition_table_config.Config = profile.config.partition_table_cfg;
    partition_cfg.partition_table_custom = true;
    partition_cfg.partition_table_custom_filename = partition_csv_filename;
    partition_cfg.partition_table_filename = partition_csv_filename;
    partition_cfg.partition_table_offset = partition_offset_hex;
    return partition_cfg;
}

fn validatePartitionTable(table: partition.Table) void {
    partition.validateEntries(table.entries) catch {
        @panic("partition table must include app/factory partition");
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
