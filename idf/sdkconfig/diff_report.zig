const std = @import("std");

const KeyValues = std.StringHashMap([]const u8);

const DiffStats = struct {
    generated_total: usize,
    final_total: usize,
    matched: usize,
    changed: usize,
    missing: usize,
    extra: usize,
};

const PrefixCount = struct {
    prefix: []const u8,
    count: usize,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 4) {
        std.debug.print(
            "usage: sdkconfig_diff_report <generated-sdkconfig> <idf-final-sdkconfig> <report-output-path>\n",
            .{},
        );
        return error.InvalidArguments;
    }

    const generated_path = args[1];
    const final_path = args[2];
    const report_path = args[3];

    const generated_content = try std.fs.cwd().readFileAlloc(allocator, generated_path, 8 * 1024 * 1024);
    defer allocator.free(generated_content);

    const final_content = try std.fs.cwd().readFileAlloc(allocator, final_path, 8 * 1024 * 1024);
    defer allocator.free(final_content);

    var generated_map = try parseSdkconfig(allocator, generated_content);
    defer freeKeyValues(allocator, &generated_map);

    var final_map = try parseSdkconfig(allocator, final_content);
    defer freeKeyValues(allocator, &final_map);

    const report = try renderDiffReport(allocator, generated_path, final_path, &generated_map, &final_map);
    defer allocator.free(report);

    if (std.fs.path.dirname(report_path)) |dir_name| {
        try std.fs.cwd().makePath(dir_name);
    }

    try std.fs.cwd().writeFile(.{
        .sub_path = report_path,
        .data = report,
    });
}

fn parseSdkconfig(allocator: std.mem.Allocator, content: []const u8) !KeyValues {
    var map = KeyValues.init(allocator);
    errdefer freeKeyValues(allocator, &map);

    var lines = std.mem.splitScalar(u8, content, '\n');
    while (lines.next()) |line| {
        const maybe_entry = parseLine(line) orelse continue;
        try putKeyValue(allocator, &map, maybe_entry.key, maybe_entry.value);
    }

    return map;
}

const ParsedLine = struct {
    key: []const u8,
    value: []const u8,
};

fn parseLine(raw_line: []const u8) ?ParsedLine {
    const line = std.mem.trim(u8, raw_line, " \t\r");
    if (line.len == 0) return null;

    if (std.mem.startsWith(u8, line, "# CONFIG_") and std.mem.endsWith(u8, line, " is not set")) {
        const key = line[2 .. line.len - " is not set".len];
        return .{ .key = key, .value = "n" };
    }

    if (!std.mem.startsWith(u8, line, "CONFIG_")) return null;

    const eq = std.mem.indexOfScalar(u8, line, '=') orelse return null;
    const key = std.mem.trim(u8, line[0..eq], " \t");
    const value = std.mem.trim(u8, line[eq + 1 ..], " \t");

    if (key.len == 0) return null;
    return .{ .key = key, .value = value };
}

fn putKeyValue(
    allocator: std.mem.Allocator,
    map: *KeyValues,
    key: []const u8,
    value: []const u8,
) !void {
    if (map.getEntry(key)) |existing| {
        const value_copy = try allocator.dupe(u8, value);
        allocator.free(existing.value_ptr.*);
        existing.value_ptr.* = value_copy;
        return;
    }

    const key_copy = try allocator.dupe(u8, key);
    errdefer allocator.free(key_copy);

    const value_copy = try allocator.dupe(u8, value);
    errdefer allocator.free(value_copy);

    try map.put(key_copy, value_copy);
}

fn freeKeyValues(allocator: std.mem.Allocator, map: *KeyValues) void {
    var it = map.iterator();
    while (it.next()) |entry| {
        allocator.free(entry.key_ptr.*);
        allocator.free(entry.value_ptr.*);
    }
    map.deinit();
}

fn renderDiffReport(
    allocator: std.mem.Allocator,
    generated_path: []const u8,
    final_path: []const u8,
    generated: *const KeyValues,
    final: *const KeyValues,
) ![]u8 {
    var matched: usize = 0;
    var changed = std.array_list.Managed([]const u8).init(allocator);
    defer changed.deinit();
    var missing = std.array_list.Managed([]const u8).init(allocator);
    defer missing.deinit();
    var extra = std.array_list.Managed([]const u8).init(allocator);
    defer extra.deinit();

    var final_it = final.iterator();
    while (final_it.next()) |entry| {
        const key = entry.key_ptr.*;
        const final_value = entry.value_ptr.*;
        if (generated.get(key)) |generated_value| {
            if (std.mem.eql(u8, generated_value, final_value)) {
                matched += 1;
            } else {
                try changed.append(key);
            }
        } else {
            try missing.append(key);
        }
    }

    var generated_it = generated.iterator();
    while (generated_it.next()) |entry| {
        const key = entry.key_ptr.*;
        if (!final.contains(key)) {
            try extra.append(key);
        }
    }

    std.sort.heap([]const u8, changed.items, {}, lessString);
    std.sort.heap([]const u8, missing.items, {}, lessString);
    std.sort.heap([]const u8, extra.items, {}, lessString);

    const stats = DiffStats{
        .generated_total = generated.count(),
        .final_total = final.count(),
        .matched = matched,
        .changed = changed.items.len,
        .missing = missing.items.len,
        .extra = extra.items.len,
    };

    var prefix_count = std.StringHashMap(usize).init(allocator);
    defer prefix_count.deinit();

    for (missing.items) |key| {
        const prefix = keyPrefix(key);
        const gop = try prefix_count.getOrPut(prefix);
        if (!gop.found_existing) {
            gop.value_ptr.* = 1;
        } else {
            gop.value_ptr.* += 1;
        }
    }

    var prefix_items = std.array_list.Managed(PrefixCount).init(allocator);
    defer prefix_items.deinit();
    var prefix_it = prefix_count.iterator();
    while (prefix_it.next()) |entry| {
        try prefix_items.append(.{
            .prefix = entry.key_ptr.*,
            .count = entry.value_ptr.*,
        });
    }
    std.sort.heap(PrefixCount, prefix_items.items, {}, lessPrefixCount);

    var out = std.array_list.Managed(u8).init(allocator);
    errdefer out.deinit();
    const writer = out.writer();

    try writer.print("# SDKCONFIG COVERAGE REPORT\n", .{});
    try writer.print("generated: {s}\n", .{generated_path});
    try writer.print("idf_final: {s}\n\n", .{final_path});

    try writer.print("generated_keys={d}\n", .{stats.generated_total});
    try writer.print("idf_final_keys={d}\n", .{stats.final_total});
    try writer.print("matched_keys={d}\n", .{stats.matched});
    try writer.print("changed_keys={d}\n", .{stats.changed});
    try writer.print("missing_keys={d}\n", .{stats.missing});
    try writer.print("extra_keys={d}\n\n", .{stats.extra});

    try writer.writeAll("## missing key prefix distribution\n");
    for (prefix_items.items) |item| {
        try writer.print("- {s}: {d}\n", .{ item.prefix, item.count });
    }
    try writer.writeByte('\n');

    try writeKeyList(writer, "## changed keys", changed.items);
    try writer.writeByte('\n');
    try writeKeyList(writer, "## missing keys", missing.items);
    try writer.writeByte('\n');
    try writeKeyList(writer, "## extra keys", extra.items);

    return out.toOwnedSlice();
}

fn keyPrefix(key: []const u8) []const u8 {
    if (!std.mem.startsWith(u8, key, "CONFIG_")) return key;
    const rest = key["CONFIG_".len..];
    const cut = std.mem.indexOfScalar(u8, rest, '_') orelse return rest;
    return rest[0..cut];
}

fn writeKeyList(writer: anytype, title: []const u8, keys: []const []const u8) !void {
    try writer.print("{s}\n", .{title});
    if (keys.len == 0) {
        try writer.writeAll("- (none)\n");
        return;
    }

    for (keys) |key| {
        try writer.print("- {s}\n", .{key});
    }
}

fn lessString(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs) == .lt;
}

fn lessPrefixCount(_: void, lhs: PrefixCount, rhs: PrefixCount) bool {
    if (lhs.count == rhs.count) {
        return std.mem.order(u8, lhs.prefix, rhs.prefix) == .lt;
    }
    return lhs.count > rhs.count;
}

test "parseLine supports set and unset forms" {
    const set_line = parseLine("CONFIG_A=42") orelse return error.TestExpectedEqual;
    try std.testing.expect(std.mem.eql(u8, set_line.key, "CONFIG_A"));
    try std.testing.expect(std.mem.eql(u8, set_line.value, "42"));

    const unset_line = parseLine("# CONFIG_B is not set") orelse return error.TestExpectedEqual;
    try std.testing.expect(std.mem.eql(u8, unset_line.key, "CONFIG_B"));
    try std.testing.expect(std.mem.eql(u8, unset_line.value, "n"));
}

test "renderDiffReport computes missing and changed keys" {
    const generated_text =
        "CONFIG_A=y\n" ++
        "CONFIG_B=1\n" ++
        "# CONFIG_C is not set\n";

    const final_text =
        "CONFIG_A=y\n" ++
        "CONFIG_B=2\n" ++
        "CONFIG_D=hello\n";

    var generated = try parseSdkconfig(std.testing.allocator, generated_text);
    defer freeKeyValues(std.testing.allocator, &generated);
    var final = try parseSdkconfig(std.testing.allocator, final_text);
    defer freeKeyValues(std.testing.allocator, &final);

    const report = try renderDiffReport(
        std.testing.allocator,
        "generated",
        "final",
        &generated,
        &final,
    );
    defer std.testing.allocator.free(report);

    try std.testing.expect(std.mem.indexOf(u8, report, "changed_keys=1") != null);
    try std.testing.expect(std.mem.indexOf(u8, report, "missing_keys=1") != null);
    try std.testing.expect(std.mem.indexOf(u8, report, "extra_keys=1") != null);
    try std.testing.expect(std.mem.indexOf(u8, report, "- CONFIG_B") != null);
    try std.testing.expect(std.mem.indexOf(u8, report, "- CONFIG_D") != null);
    try std.testing.expect(std.mem.indexOf(u8, report, "- CONFIG_C") != null);
}
