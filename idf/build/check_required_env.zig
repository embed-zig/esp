const std = @import("std");

const required_env_vars = [_][]const u8{"ESP_IDF"};
const export_guard_var = "IDF_PYTHON_ENV_PATH";

pub fn main() !void {
    var missing = std.array_list.Managed([]const u8).init(std.heap.page_allocator);
    defer missing.deinit();

    inline for (required_env_vars) |name| {
        if (!isEnvSet(name)) {
            try missing.append(name);
        }
    }

    if (missing.items.len > 0) {
        var joined_missing = std.array_list.Managed(u8).init(std.heap.page_allocator);
        defer joined_missing.deinit();

        for (missing.items, 0..) |name, index| {
            if (index > 0) {
                try joined_missing.appendSlice(", ");
            }
            try joined_missing.appendSlice(name);
        }

        std.debug.print("error: missing required environment variable(s): {s}\n", .{joined_missing.items});
        std.debug.print("please set ESP_IDF before running idf workflow commands.\n", .{});
        std.debug.print("example:\n", .{});
        std.debug.print("  export ESP_IDF=/path/to/esp-idf\n", .{});
        std.debug.print("then run:\n", .{});
        std.debug.print("  source $ESP_IDF/export.sh\n", .{});
        std.debug.print("finally rerun your zig command (for example: zig build configure).\n", .{});
        return error.MissingRequiredEnvironmentVariables;
    }

    const esp_idf = getEnvValueOwned("ESP_IDF") orelse return error.MissingRequiredEnvironmentVariables;
    defer std.heap.page_allocator.free(esp_idf);

    if (!isEnvSet(export_guard_var)) {
        std.debug.print("error: ESP-IDF environment is not activated in this shell.\n", .{});
        std.debug.print("please run the following command first:\n", .{});
        std.debug.print("  source {s}/export.sh\n", .{esp_idf});
        std.debug.print("then rerun your zig command (for example: zig build configure).\n", .{});
        return error.MissingIdfExportEnvironment;
    }
}

fn isEnvSet(name: []const u8) bool {
    const value = getEnvValueOwned(name) orelse return false;
    defer std.heap.page_allocator.free(value);

    return true;
}

fn getEnvValueOwned(name: []const u8) ?[]u8 {
    const value = std.process.getEnvVarOwned(std.heap.page_allocator, name) catch |err| switch (err) {
        error.EnvironmentVariableNotFound => return null,
        else => return null,
    };

    const trimmed = std.mem.trim(u8, value, " \t\r\n");
    if (trimmed.len == 0) {
        std.heap.page_allocator.free(value);
        return null;
    }

    if (trimmed.ptr == value.ptr and trimmed.len == value.len) {
        return value;
    }

    const copied = std.heap.page_allocator.dupe(u8, trimmed) catch {
        std.heap.page_allocator.free(value);
        return null;
    };
    std.heap.page_allocator.free(value);
    return copied;
}
