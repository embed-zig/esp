const std = @import("std");
const esp = @import("esp");
const hal = esp.hal;
const gpio = esp.component.esp_driver_gpio;
const rom = esp.component.esp_rom;
const heap = esp.component.heap;
const board_mod = @import("board");

const audio_codec = hal.audio_system.es7210_es8311;

const printf = rom.esp_rom_printf;
const b = board_mod.pins;

const has_bsp = @hasDecl(board_mod, "audio");

const SAMPLE_RATE: u32 = 16_000;

pub const AudioDriver = audio_codec.Driver;

pub const Board = struct {
    i2c_driver: hal.I2c.DriverType,
    audio: *AudioDriver,
    allocator: std.mem.Allocator,

    var g_i2c_bus: hal.I2c.DriverType = undefined;
    var g_expander: Pca9557 = undefined;

    pub fn init(allocator: std.mem.Allocator) ?*Board {
        const self = allocator.create(Board) catch {
            _ = printf("FATAL: board alloc failed\n");
            return null;
        };

        self.allocator = allocator;

        self.i2c_driver = hal.I2c.DriverType.initMaster(.{
            .port = @intCast(b.i2c.port),
            .sda = @intCast(b.i2c.sda),
            .scl = @intCast(b.i2c.scl),
            .freq_hz = b.i2c.freq_hz,
        }) catch {
            _ = printf("FATAL: I2C init failed\n");
            return null;
        };
        _ = printf("board: I2C OK\n");

        initPa();

        const audio_cfg = if (has_bsp) board_mod.audio else audio_codec.Config{
            .i2s = .{
                .port = @intCast(b.i2s.port),
                .mclk = @intCast(b.i2s.mclk),
                .bclk = @intCast(b.i2s.bclk),
                .ws = @intCast(b.i2s.ws),
                .din = @intCast(b.i2s.din),
                .dout = @intCast(b.i2s.dout),
            },
            .sample_rate = SAMPLE_RATE,
            .mic_codec_address = b.es7210.i2c_addr,
            .spk_codec = .{
                .address = b.es8311.i2c_addr,
                .codec_mode = .both,
                .no_dac_ref = false,
            },
            .mics = b.audio.mics,
            .ref = b.audio.ref,
            .frame_samples = b.audio.frame_samples,
            .spk_initial_volume = b.audio.spk_initial_volume,
        };

        self.audio = AudioDriver.init(allocator, &self.i2c_driver, audio_cfg) catch {
            _ = printf("FATAL: audio system init failed\n");
            return null;
        };
        _ = printf("board: audio system OK\n");

        _ = printf("board: init complete (internal free=%u)\n", heap.freeInternalHeapSize());
        return self;
    }

    fn initPa() void {
        if (has_bsp and @hasDecl(board_mod, "paEnable")) {
            board_mod.paEnable(false);
            _ = printf("board: PA (BSP) OK\n");
        } else if (@hasField(@TypeOf(b.pa), "gpio")) {
            gpio.setDirection(@intCast(b.pa.gpio), .output) catch {
                _ = printf("WARN: PA GPIO config failed\n");
            };
            gpio.setLevel(@intCast(b.pa.gpio), 0) catch {};
            _ = printf("board: PA GPIO %d OK\n", @as(i32, b.pa.gpio));
        } else {
            g_i2c_bus = undefined;
            g_expander = Pca9557.init(
                &g_i2c_bus,
                @truncate(b.pa.i2c_addr),
                b.pa.output_port_reg,
                b.pa.config_port_reg,
                b.pa.init_output,
                b.pa.init_config,
            );
            _ = printf("board: PCA9557 OK\n");
        }
    }

    pub fn paEnable(en: bool) void {
        if (has_bsp and @hasDecl(board_mod, "paEnable")) {
            board_mod.paEnable(en);
        } else if (@hasField(@TypeOf(b.pa), "gpio")) {
            gpio.setLevel(@intCast(b.pa.gpio), if (en) @as(u32, 1) else @as(u32, 0)) catch {};
        } else {
            g_expander.setBit(b.pa.pa_bit, en);
        }
    }
};

const Pca9557 = struct {
    i2c: *hal.I2c.DriverType,
    addr: u7,
    output_reg: u8,
    dev_handle: hal.I2c.DriverType.DeviceHandle,

    pub fn init(
        i2c: *hal.I2c.DriverType,
        addr: u7,
        output_reg: u8,
        config_reg: u8,
        init_output: u8,
        init_config: u8,
    ) Pca9557 {
        const dev = i2c.registerDevice(.{ .address = addr }) catch return .{
            .i2c = i2c,
            .addr = addr,
            .output_reg = output_reg,
            .dev_handle = .{ .address = addr, .timeout_ms = 0 },
        };
        i2c.write(dev, &.{ output_reg, init_output }) catch {};
        i2c.write(dev, &.{ config_reg, init_config }) catch {};
        return .{ .i2c = i2c, .addr = addr, .output_reg = output_reg, .dev_handle = dev };
    }

    pub fn setBit(self: *Pca9557, bit: u8, level: bool) void {
        var read_buf: [1]u8 = undefined;
        self.i2c.writeRead(self.dev_handle, &.{self.output_reg}, &read_buf) catch return;
        var output = read_buf[0];
        if (level) {
            output |= bit;
        } else {
            output &= ~bit;
        }
        self.i2c.write(self.dev_handle, &.{ self.output_reg, output }) catch {};
    }
};
