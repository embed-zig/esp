const std = @import("std");
const esp = @import("esp");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const color = b.option([]const u8, "color", "LED color: red or green (default red)") orelse "red";

    _ = esp.idf.build.registerApp(b, "ota_led", .{
        .target = target,
        .optimize = optimize,
        .build_options = &.{
            .{
                .name = "color",
                .value = .{ .string = color },
            },
        },
        .embed_links = .{},
    });
}
