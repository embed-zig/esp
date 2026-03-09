const std = @import("std");
const esp = @import("esp");

const default_build_config = "board/esp32s3_devkit.zig";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const deprecated_board = b.option([]const u8, "board", "DEPRECATED: use -Dbuild_config instead");
    const build_config = b.option([]const u8, "build_config", "Board build config file path") orelse deprecated_board orelse default_build_config;
    const bsp_file = b.option([]const u8, "bsp", "Board BSP file (optional, enables @import(\"esp\") in board)");
    const build_dir = b.option([]const u8, "build_dir", "Directory for all generated workflow files") orelse "build";

    if (deprecated_board != null) {
        std.log.warn("-Dboard is deprecated, use -Dbuild_config instead", .{});
    }

    const runtime = esp.idf.build.externalRuntimeOptionsFromBuild(b);

    _ = esp.idf.build.registerApp(b, .{
        .target = target,
        .optimize = optimize,
        .app_name = "led_strip",
        .build_config = build_config,
        .bsp_file = bsp_file,
        .build_dir = build_dir,
        .runtime = runtime,
    });
}
