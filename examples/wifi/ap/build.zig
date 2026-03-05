const std = @import("std");
const espz = @import("espz");

const default_board_file = "board/esp32s3_devkit.zig";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const board_file = b.option([]const u8, "board", "Board sdkconfig profile Zig file path") orelse default_board_file;
    const build_dir = b.option([]const u8, "build_dir", "Directory for all generated workflow files") orelse "build";

    const runtime = espz.workflow.externalRuntimeOptionsFromBuild(b);

    _ = espz.registerApp(b, .{
        .target = target,
        .optimize = optimize,
        .app_name = "wifi_ap",
        .board_file = board_file,
        .build_dir = build_dir,
        .compile_check_with_idf_module = false,
        .runtime = runtime,
    });
}
