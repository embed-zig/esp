const std = @import("std");
const idf_workflow = @import("idf/build/workflow.zig");

pub const workflow = idf_workflow;

pub const AppOptions = struct {
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,

    app_name: []const u8,
    board_file: []const u8,
    build_dir: []const u8 = "build",

    /// Whether to compile-check the app against the esp-idf module during build graph construction.
    /// Set to false if the app depends on ESP-IDF headers that are only available during idf-build.
    compile_check_with_idf_module: bool = true,

    /// Controls which unprefixed build steps are exposed (runtime_only, full, etc.)
    unprefixed_step_profile: idf_workflow.UnprefixedStepProfile = .runtime_only,

    /// Additional Zig modules to expose to the app firmware code via @import.
    /// Each module is mapped to a name that can be used in the app source.
    extra_zig_modules: []const idf_workflow.ExtraZigModule = &.{},

    runtime: idf_workflow.ExternalRuntimeOptions,
};

pub fn registerApp(
    b: *std.Build,
    options: AppOptions,
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
        .extra_zig_modules = options.extra_zig_modules,
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
