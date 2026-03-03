const std = @import("std");
const test_options = @import("test_options");

test "withDefaultConfig rejects unknown override fields" {
    const allocator = std.testing.allocator;
    const argv = [_][]const u8{
        test_options.zig_exe_path,
        "build-exe",
        "--dep",
        "utils",
        "-Mroot=test/fixtures/with_default_config_unknown_field.zig",
        "-Mutils=src/utils/root.zig",
        "-fno-emit-bin",
    };

    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = &argv,
    });
    defer allocator.free(result.stdout);
    defer allocator.free(result.stderr);

    switch (result.term) {
        .Exited => |code| try std.testing.expect(code != 0),
        else => return error.TestUnexpectedResult,
    }

    try std.testing.expect(
        std.mem.indexOf(u8, result.stderr, "withDefaultConfig unknown field 'not_a_field'") != null,
    );
}
