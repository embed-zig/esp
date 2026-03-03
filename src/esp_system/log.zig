//! esp_system.log 最小可用实现。
//!
//! 设计目标：
//! 1. 对外暴露 `info` / `warn` / `err`，签名固定为 `[]const u8`，错误类型在编译期暴露。
//! 2. 默认行为打印到标准错误输出，保证接口可直接调用。
//! 3. 支持测试期注入 sink，以验证边界输入（如空字符串）。

const std = @import("std");

pub const Level = enum {
    info,
    warn,
    err,
};

pub const Sink = *const fn (level: Level, message: []const u8) void;

var global_sink: Sink = defaultSink;

fn defaultSink(level: Level, message: []const u8) void {
    std.debug.print("{s}: {s}\n", .{ levelTag(level), message });
}

fn levelTag(level: Level) []const u8 {
    return switch (level) {
        .info => "I",
        .warn => "W",
        .err => "E",
    };
}

pub fn setSink(sink: Sink) void {
    global_sink = sink;
}

pub fn resetSink() void {
    global_sink = defaultSink;
}

pub fn info(message: []const u8) void {
    global_sink(.info, message);
}

pub fn warn(message: []const u8) void {
    global_sink(.warn, message);
}

pub fn err(message: []const u8) void {
    global_sink(.err, message);
}

test "info accepts empty string" {
    const Capture = struct {
        var called: usize = 0;
        var saw_empty: bool = false;

        fn sink(level: Level, message: []const u8) void {
            _ = level;
            called += 1;
            saw_empty = message.len == 0;
        }
    };

    setSink(Capture.sink);
    defer resetSink();

    info("");

    try std.testing.expectEqual(@as(usize, 1), Capture.called);
    try std.testing.expect(Capture.saw_empty);
}
