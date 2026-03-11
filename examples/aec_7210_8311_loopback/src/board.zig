const esp = @import("esp");
const esp_component = esp.component;
const rom = esp_component.esp_rom;
const heap = esp_component.heap;
const i2c = esp_component.esp_driver_i2c;
const i2s = esp_component.esp_driver_i2s;
const gpio = esp_component.esp_driver_gpio;
pub const board_pins = @import("board");

const es7210 = @import("es7210.zig");
const es8311 = @import("es8311.zig");

const printf = rom.esp_rom_printf;
const b = board_pins.pins;

const SAMPLE_RATE: u32 = 16_000;
const I2C_TIMEOUT_MS: u32 = 100;

const pa_is_gpio = @hasField(@TypeOf(b.pa), "gpio");

pub const I2cBus = struct {
    master: i2c.I2cMaster,

    pub fn init(master_inst: i2c.I2cMaster) I2cBus {
        return .{ .master = master_inst };
    }

    pub fn write(self: *I2cBus, addr: u7, data: []const u8) !void {
        try self.master.write(@intCast(addr), data, I2C_TIMEOUT_MS);
    }

    pub fn writeRead(self: *I2cBus, addr: u7, write_data: []const u8, read_data: []u8) !void {
        try self.master.writeRead(@intCast(addr), write_data, read_data, I2C_TIMEOUT_MS);
    }
};

pub const Pca9557 = struct {
    bus: *I2cBus,
    addr: u7,
    output_reg: u8,

    pub fn init(bus: *I2cBus, addr: u7, output_reg: u8, config_reg: u8, init_output: u8, init_config: u8) Pca9557 {
        bus.write(addr, &.{ output_reg, init_output }) catch {};
        bus.write(addr, &.{ config_reg, init_config }) catch {};
        return .{ .bus = bus, .addr = addr, .output_reg = output_reg };
    }

    pub fn setBit(self: *Pca9557, bit: u8, level: bool) void {
        var read_buf: [1]u8 = undefined;
        self.bus.writeRead(self.addr, &.{self.output_reg}, &read_buf) catch return;
        var output = read_buf[0];
        if (level) {
            output |= bit;
        } else {
            output &= ~bit;
        }
        self.bus.write(self.addr, &.{ self.output_reg, output }) catch {};
    }
};

pub const Board = struct {
    duplex: ?i2s.I2sDuplex,

    var g_i2c_bus: I2cBus = undefined;
    var g_expander: Pca9557 = undefined;

    pub fn init() ?Board {
        const i2c_master = i2c.I2cMaster.init(.{
            .port = b.i2c.port,
            .sda = b.i2c.sda,
            .scl = b.i2c.scl,
            .freq_hz = b.i2c.freq_hz,
        }) catch {
            _ = printf("FATAL: I2C init failed\n");
            return null;
        };
        g_i2c_bus = I2cBus.init(i2c_master);
        _ = printf("board: I2C OK\n");

        if (pa_is_gpio) {
            gpio.setDirection(@intCast(b.pa.gpio), .output) catch {
                _ = printf("WARN: PA GPIO config failed\n");
            };
            gpio.setLevel(@intCast(b.pa.gpio), 0) catch {};
            _ = printf("board: PA GPIO %d OK\n", @as(i32, b.pa.gpio));
        } else {
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

        // ES8311: DAC + ADC codec
        // dacVolumeReg: 4.0dB → (4.0+95.5)*2 = 199
        var codec = es8311.Es8311(*I2cBus).init(&g_i2c_bus, .{
            .address = b.es8311.i2c_addr,
            .codec_mode = .both,
            .no_dac_ref = false,
        });
        codec.open() catch {
            _ = printf("FATAL: ES8311 open failed\n");
            return null;
        };
        codec.setSampleRate(SAMPLE_RATE) catch {};
        codec.setBitsPerSample(.@"16bit") catch {};
        codec.setMicGain(.@"24dB") catch {};
        codec.setVolume(199) catch {};
        codec.enable(true) catch {};
        _ = printf("board: ES8311 OK (vol=199/4.0dB)\n");

        // ES7210: 4-ch ADC, mic1+mic2 for capture, mic3 for hardware ref loopback
        var adc_dev = es7210.Es7210(*I2cBus).init(&g_i2c_bus, .{
            .address = b.es7210.i2c_addr,
            .mic_select = .{ .mic1 = true, .mic2 = true, .mic3 = true },
        });
        adc_dev.open() catch {
            _ = printf("FATAL: ES7210 open failed\n");
            return null;
        };
        adc_dev.setSampleRate(b.i2s.sample_rate) catch {};
        adc_dev.setBitsPerSample(.@"16bit") catch {};

        adc_dev.enable(true) catch {};
        adc_dev.setChannelGain(0, .@"24dB") catch {};
        adc_dev.setChannelGain(1, .@"24dB") catch {};
        adc_dev.setChannelGain(2, .@"21dB") catch {};
        _ = printf("board: ES7210 OK (mic1/2=24dB, ref/CH3=21dB)\n");

        // I2S duplex: both TX and RX are 32-bit STD stereo.
        // ES7210 16-bit TDM packs 4 channels into 2×32-bit slots:
        //   L[31:16]=CH1, L[15:0]=CH3, R[31:16]=CH2, R[15:0]=CH4
        // ES8311 expects i16 in the high 16 bits of each 32-bit slot.
        const duplex = i2s.I2sDuplex.init(.{
            .port = b.i2s.port,
            .role = .master,
            .rx = .{
                .sample_rate_hz = SAMPLE_RATE,
                .bits_per_sample = .bits32,
                .mode = .std,
                .slot_mode = .stereo,
                .tdm_slot_mask = 0,
                .mclk = b.i2s.mclk,
                .bclk = b.i2s.bclk,
                .ws = b.i2s.ws,
                .din = b.i2s.din,
                .dma_desc_num = 8,
                .dma_frame_num = 320,
            },
            .tx = .{
                .sample_rate_hz = SAMPLE_RATE,
                .bits_per_sample = .bits32,
                .mode = .std,
                .slot_mode = .stereo,
                .tdm_slot_mask = 0,
                .mclk = b.i2s.mclk,
                .bclk = b.i2s.bclk,
                .ws = b.i2s.ws,
                .dout = b.i2s.dout,
                .dma_desc_num = 8,
                .dma_frame_num = 320,
            },
        }) catch {
            _ = printf("FATAL: I2S duplex init failed\n");
            return null;
        };
        _ = printf("board: I2S OK (32-bit stereo duplex)\n");

        _ = printf("board: init complete (internal free=%u)\n", heap.freeInternalHeapSize());
        return .{ .duplex = duplex };
    }

    pub fn paEnable(en: bool) void {
        if (pa_is_gpio) {
            gpio.setLevel(@intCast(b.pa.gpio), if (en) @as(u32, 1) else @as(u32, 0)) catch {};
        } else {
            g_expander.setBit(b.pa.pa_bit, en);
        }
    }
};
