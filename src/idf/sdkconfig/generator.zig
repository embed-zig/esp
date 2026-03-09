const std = @import("std");
const board_adapter = @import("board_adapter.zig");
const sdkconfig = @import("idf").sdkconfig;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 4) {
        std.debug.print(
            "usage: sdkconfig_generator <sdkconfig-output-path> <partition-csv-output-path> <partition-filename-for-idf>\n",
            .{},
        );
        return error.InvalidArguments;
    }

    const sdkconfig_output_path = args[1];
    const partition_output_path = args[2];
    const partition_filename_for_idf = args[3];

    const docs = try board_adapter.collectModuleDocs(allocator, partition_filename_for_idf);
    defer sdkconfig.freeModuleDocs(allocator, docs);

    const rendered = try sdkconfig.render(allocator, docs);
    defer allocator.free(rendered);

    if (std.fs.path.dirname(sdkconfig_output_path)) |dir_name| {
        try std.fs.cwd().makePath(dir_name);
    }

    try std.fs.cwd().writeFile(.{
        .sub_path = sdkconfig_output_path,
        .data = rendered,
    });

    const sdkconfig_preconfigure_path = try preconfigureSnapshotPath(allocator, sdkconfig_output_path);
    defer allocator.free(sdkconfig_preconfigure_path);
    try std.fs.cwd().writeFile(.{
        .sub_path = sdkconfig_preconfigure_path,
        .data = rendered,
    });

    const partitions_csv = try board_adapter.renderPartitionCsv(allocator);
    defer allocator.free(partitions_csv);

    if (std.fs.path.dirname(partition_output_path)) |dir_name| {
        try std.fs.cwd().makePath(dir_name);
    }

    try std.fs.cwd().writeFile(.{
        .sub_path = partition_output_path,
        .data = partitions_csv,
    });
}

fn preconfigureSnapshotPath(allocator: std.mem.Allocator, sdkconfig_output_path: []const u8) ![]u8 {
    if (std.fs.path.dirname(sdkconfig_output_path)) |dir_name| {
        return try std.fs.path.join(allocator, &.{ dir_name, "sdkconfig.preconfigure.generated" });
    }
    return allocator.dupe(u8, "sdkconfig.preconfigure.generated");
}
