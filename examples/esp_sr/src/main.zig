const std = @import("std");
const rom = @import("esp_rom");
const freertos = @import("freertos");
const aec = @import("aec.zig");

const printf = rom.esp_rom_printf;

extern fn abort() noreturn;

pub const std_options: std.Options = .{
    .logFn = struct {
        fn log(
            comptime _: std.log.Level,
            comptime _: @TypeOf(.enum_literal),
            comptime _: []const u8,
            _: anytype,
        ) void {}
    }.log,
};

pub fn panic(msg: []const u8, _: ?*std.builtin.StackTrace, _: ?usize) noreturn {
    _ = printf("\n*** ZIG PANIC ***\n");
    for (msg) |ch| {
        _ = printf("%c", @as(i32, ch));
    }
    _ = printf("\n*****************\n");
    abort();
}

export fn zig_esp_main() callconv(.c) void {
    aec.run();

    while (true) {
        freertos.delay(10000);
    }
}
