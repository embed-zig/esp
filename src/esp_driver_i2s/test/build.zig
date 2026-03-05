const std = @import("std");
const espz = @import("espz");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const board_file = b.option([]const u8, "board", "Board sdkconfig profile Zig file path") orelse "board/esp32s3.zig";
    const build_dir = b.option([]const u8, "build_dir", "Directory for all generated workflow files") orelse "build";

    const runtime = espz.workflow.externalRuntimeOptionsFromBuild(b);

    _ = espz.registerApp(b, .{
        .target = target,
        .optimize = optimize,
        .app_name = "esp_driver_i2s_compile_test",
        .board_file = board_file,
        .build_dir = build_dir,
        .compile_check_with_idf_module = false,
        .unprefixed_step_profile = .full,
        .runtime = runtime,
    });
}
