const std = @import("std");
const build_config = @import("build_config");
const idf = @import("idf");
const partition = idf.partition;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 7) {
        std.debug.print(
            "usage: data_partitions <flash> <app_root> <build_dir> <esp_idf> <wrapper_path> <port>\n",
            .{},
        );
        return error.InvalidArgs;
    }

    const mode = args[1];
    const app_root = args[2];
    const build_dir = args[3];
    const esp_idf = args[4];
    const wrapper_path = args[5];
    const port = args[6];

    if (!std.mem.eql(u8, mode, "flash")) {
        return error.InvalidArgs;
    }

    const table = build_config.config.partition_table;
    try partition.validateEntries(table.entries);
    const resolved_entries = try partition.resolveEntriesAlloc(allocator, table);
    try flashDataPartitions(allocator, app_root, build_dir, esp_idf, wrapper_path, port, resolved_entries);
}

fn flashDataPartitions(
    allocator: std.mem.Allocator,
    _: []const u8,
    build_dir: []const u8,
    esp_idf: []const u8,
    wrapper_path: []const u8,
    port: []const u8,
    entries: anytype,
) !void {
    for (entries) |entry| {
        if (!@hasField(@TypeOf(entry), "data")) continue;
        const maybe_data = entry.data;
        if (maybe_data == null) continue;

        const output_name = try std.fmt.allocPrint(allocator, "{s}.bin", .{entry.name});
        defer allocator.free(output_name);
        const output_bin = try std.fs.path.join(allocator, &.{ build_dir, output_name });
        defer allocator.free(output_bin);

        switch (maybe_data.?) {
            .spiffs => |cfg| {
                const source_dir = try std.fs.path.join(allocator, &.{cfg.dir});
                defer allocator.free(source_dir);
                const spiffsgen_path = try std.fs.path.join(allocator, &.{ esp_idf, "components", "spiffs", "spiffsgen.py" });
                defer allocator.free(spiffsgen_path);
                const size_arg = try std.fmt.allocPrint(allocator, "0x{x}", .{entry.size});
                defer allocator.free(size_arg);
                try runCommand(allocator, &.{
                    "bash",
                    wrapper_path,
                    esp_idf,
                    "python3",
                    spiffsgen_path,
                    size_arg,
                    source_dir,
                    output_bin,
                    "--page-size",
                    "256",
                    "--block-size",
                    "4096",
                }, ".");
            },
            .littlefs => {
                return error.LittlefsNotImplemented;
            },
            .raw_file => |path| {
                const source_path = try std.fs.path.join(allocator, &.{path});
                defer allocator.free(source_path);
                try copyFile(source_path, output_bin);
            },
            .nvs => |cfg| {
                const csv_name = try std.fmt.allocPrint(allocator, "{s}.csv", .{entry.name});
                defer allocator.free(csv_name);
                const csv_path = try std.fs.path.join(allocator, &.{ build_dir, csv_name });
                defer allocator.free(csv_path);
                const csv = try partition.nvsCsvAlloc(allocator, cfg.entries);
                defer allocator.free(csv);
                try writeFileRelative(csv_path, csv);
                const size_arg = try std.fmt.allocPrint(allocator, "{d}", .{entry.size});
                defer allocator.free(size_arg);
                try runCommand(allocator, &.{
                    "bash",
                    wrapper_path,
                    esp_idf,
                    "python3",
                    "-m",
                    "esp_idf_nvs_partition_gen",
                    "generate",
                    csv_path,
                    output_bin,
                    size_arg,
                }, ".");
            },
        }

        if (output_bin.len != 0) {
            var flash_args = std.array_list.Managed([]const u8).init(allocator);
            defer flash_args.deinit();
            try flash_args.appendSlice(&.{
                "bash",
                wrapper_path,
                esp_idf,
                "python3",
                "-m",
                "esptool",
            });
            if (port.len != 0) {
                try flash_args.appendSlice(&.{ "--port", port });
            }
            const offset_arg = try std.fmt.allocPrint(allocator, "0x{x}", .{entry.offset});
            defer allocator.free(offset_arg);
            try flash_args.appendSlice(&.{
                "write_flash",
                offset_arg,
                output_bin,
            });
            try runCommand(allocator, flash_args.items, ".");
        }
    }
}

fn runCommand(
    allocator: std.mem.Allocator,
    argv: []const []const u8,
    cwd: []const u8,
) !void {
    var child = std.process.Child.init(argv, allocator);
    child.cwd = cwd;
    child.stdin_behavior = .Ignore;
    child.stdout_behavior = .Inherit;
    child.stderr_behavior = .Inherit;
    try child.spawn();
    const term = try child.wait();
    switch (term) {
        .Exited => |code| if (code != 0) return error.CommandFailed,
        else => return error.CommandFailed,
    }
}

fn copyFile(source_path: []const u8, dest_path: []const u8) !void {
    const source = try std.fs.openFileAbsolute(source_path, .{});
    defer source.close();

    const dest = try std.fs.createFileAbsolute(dest_path, .{ .truncate = true });
    defer dest.close();

    var buf: [4096]u8 = undefined;
    while (true) {
        const n = try source.read(&buf);
        if (n == 0) break;
        try dest.writeAll(buf[0..n]);
    }
}

fn writeFileRelative(path: []const u8, data: []const u8) !void {
    const file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try file.writeAll(data);
}
