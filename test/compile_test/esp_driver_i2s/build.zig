const std = @import("std");
const esp = @import("esp");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const deprecated_board = b.option([]const u8, "board", "DEPRECATED: use -Dbuild_config instead");
    const build_config = b.option([]const u8, "build_config", "Board build config file path") orelse deprecated_board orelse "board/esp32s3.zig";
    const bsp_file = b.option([]const u8, "bsp", "Board BSP file (optional, enables @import(\"esp\") in board)");
    const build_dir = b.option([]const u8, "build_dir", "Directory for all generated workflow files") orelse "build";

    if (deprecated_board != null) {
        std.log.warn("-Dboard is deprecated, use -Dbuild_config instead", .{});
    }

    const runtime = esp.idf.build.externalRuntimeOptionsFromBuild(b);

    _ = esp.idf.build.registerApp(b, .{
        .target = target,
        .optimize = optimize,
        .app_name = "esp_driver_i2s_compile_test",
        .build_config = build_config,
        .bsp_file = bsp_file,
        .build_dir = build_dir,
        .runtime = runtime,
    });
}
