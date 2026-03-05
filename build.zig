const std = @import("std");
const idf_workflow = @import("idf/build/workflow.zig");

pub const workflow = idf_workflow;

pub const ExternalExampleOptions = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,

    app_name: []const u8,
    board_file: []const u8,
    build_dir: []const u8 = "build",
    compile_check_with_idf_module: bool = true,
    unprefixed_step_profile: idf_workflow.UnprefixedStepProfile = .runtime_only,

    runtime: idf_workflow.ExternalRuntimeOptions,
};

pub fn registerExternalExample(
    b: *std.Build,
    options: ExternalExampleOptions,
) idf_workflow.Registration {
    const espz_dep = b.dependency("espz", .{});

    return idf_workflow.registerExternalApp(b, .{
        .target = options.target,
        .optimize = options.optimize,
        .app_name = options.app_name,
        .board_file = options.board_file,
        .build_dir = options.build_dir,
        .entry_symbol = "zig_esp_main",
        .link_zig_entry_library = true,
        .compile_check_with_idf_module = options.compile_check_with_idf_module,
        .install_artifact = false,
        .zig_cpu = "esp32s3",
        .runtime = options.runtime,
        .espz_root = espz_dep.path(""),
        .expose_prefixed_steps = false,
        .expose_unprefixed_steps = true,
        .unprefixed_step_profile = options.unprefixed_step_profile,
    });
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = b.addModule("espz", .{
        .root_source_file = b.path("src/component.zig"),
    });
    const test_options = b.addOptions();
    test_options.addOption([]const u8, "zig_exe_path", b.graph.zig_exe);

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
    const compile_fail_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("test/compile_fail_contracts.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "test_options", .module = test_options.createModule() },
            },
        }),
    });
    const run_tests = b.addRunArtifact(convention_tests);
    const run_compile_fail_tests = b.addRunArtifact(compile_fail_tests);
    const test_step = b.step("test", "Run convention checks");
    test_step.dependOn(&run_tests.step);
    test_step.dependOn(&run_compile_fail_tests.step);
}
