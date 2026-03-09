const gpio = @import("../component/esp_driver_gpio/gpio.zig");
const hal_gpio = @import("embed").hal.gpio;

pub const Driver = struct {
    pub fn init() Driver {
        return .{};
    }

    pub fn setMode(_: *Driver, pin: u8, mode: hal_gpio.Mode) hal_gpio.Error!void {
        gpio.setDirection(@intCast(pin), switch (mode) {
            .input => .input,
            .output => .output,
            .input_output => .input_output,
        }) catch return error.GpioError;
    }

    pub fn setLevel(_: *Driver, pin: u8, level: hal_gpio.Level) hal_gpio.Error!void {
        gpio.setLevel(@intCast(pin), @intFromEnum(level)) catch return error.GpioError;
    }

    pub fn getLevel(_: *Driver, pin: u8) hal_gpio.Error!hal_gpio.Level {
        return @enumFromInt(gpio.getLevel(@intCast(pin)));
    }

    pub fn setPull(_: *Driver, pin: u8, pull: hal_gpio.Pull) hal_gpio.Error!void {
        gpio.setPullMode(@intCast(pin), switch (pull) {
            .none => .floating,
            .up => .pullup_only,
            .down => .pulldown_only,
        }) catch return error.GpioError;
    }
};
