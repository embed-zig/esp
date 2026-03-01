const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.standardTargetOptions(.{});
    _ = b.standardOptimizeOption(.{});

    // 对外只暴露一个模块：idf
    _ = b.addModule("idf", .{
        .root_source_file = b.path("src/idf.zig"),
        .link_libc = true,
    });
}
