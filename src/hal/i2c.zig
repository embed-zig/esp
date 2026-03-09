const I2cMaster = @import("../component/esp_driver_i2c/master.zig").I2cMaster;
const hal_i2c = @import("embed").hal.i2c;

pub const Driver = struct {
    port: i32 = 0,
    timeout_ms: u32 = 1000,
    master: ?I2cMaster = null,

    pub const DeviceHandle = struct {
        address: u7,
        timeout_ms: u32,
    };

    pub const Config = struct {
        port: u8 = 0,
        sda: u8,
        scl: u8,
        freq_hz: u32 = 400_000,
        timeout_ms: u32 = 1000,
    };

    pub fn initMaster(cfg: Config) hal_i2c.Error!Driver {
        const m = I2cMaster.init(.{
            .port = @intCast(cfg.port),
            .sda = @intCast(cfg.sda),
            .scl = @intCast(cfg.scl),
            .freq_hz = cfg.freq_hz,
        }) catch return error.I2cError;
        return .{
            .port = @intCast(cfg.port),
            .timeout_ms = cfg.timeout_ms,
            .master = m,
        };
    }

    pub fn init() hal_i2c.Error!Driver {
        return .{};
    }

    pub fn registerDevice(self: *Driver, cfg: hal_i2c.DeviceConfig) hal_i2c.Error!DeviceHandle {
        _ = self;
        return .{
            .address = cfg.address,
            .timeout_ms = cfg.timeout_ms,
        };
    }

    pub fn unregisterDevice(_: *Driver, _: DeviceHandle) hal_i2c.Error!void {}

    pub fn write(self: *Driver, device: DeviceHandle, data: []const u8) hal_i2c.Error!void {
        const m = self.master orelse return error.I2cError;
        const timeout_ms = if (device.timeout_ms == 0) self.timeout_ms else device.timeout_ms;
        m.write(@intCast(device.address), data, timeout_ms) catch return error.I2cError;
    }

    pub fn writeRead(self: *Driver, device: DeviceHandle, write_data: []const u8, read_buf: []u8) hal_i2c.Error!void {
        const m = self.master orelse return error.I2cError;
        const timeout_ms = if (device.timeout_ms == 0) self.timeout_ms else device.timeout_ms;
        m.writeRead(@intCast(device.address), write_data, read_buf, timeout_ms) catch return error.I2cError;
    }
};

fn mapError(err: anyerror) hal_i2c.Error {
    return switch (err) {
        error.InvalidArgument => error.InvalidParam,
        else => error.I2cError,
    };
}
