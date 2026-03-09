const std = @import("std");

pub const idf = @import("src/idf_mod.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const embed_zig_dep = b.dependency("embed_zig", .{});

    _ = b.addModule("esp", .{
        .root_source_file = b.path("src/esp_mod.zig"),
        .imports = &.{
            .{ .name = "embed", .module = embed_zig_dep.module("embed") },
        },
    });
    _ = b.addModule("idf", .{
        .root_source_file = b.path("src/idf_mod.zig"),
    });

    const esp_idf_opt = b.option([]const u8, "esp_idf", "ESP-IDF root directory for module compile tests (enables idf-build verification)");

    const test_options = b.addOptions();
    test_options.addOption([]const u8, "zig_exe_path", b.graph.zig_exe);
    test_options.addOption(?[]const u8, "esp_idf", esp_idf_opt);

    const convention_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/convention_checks.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "test_options", .module = test_options.createModule() },
            },
        }),
    });
    const run_tests = b.addRunArtifact(convention_tests);
    const test_step = b.step("test", "Run convention checks");
    test_step.dependOn(&run_tests.step);
}
