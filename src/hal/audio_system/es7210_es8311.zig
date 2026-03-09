//! ES7210 + ES8311 unified audio system driver for ESP.
//!
//! Combines the ES7210 4-channel ADC (mic capture) and ES8311 DAC (speaker
//! output) into a single driver that satisfies `hal.audio_system`.
//!
//! Key behaviors:
//!   - `readFrame` reads interleaved I2S data from ES7210, de-interleaves
//!     into per-mic buffers, and provides a ref channel from a designated
//!     mic slot or from a software speaker loopback.
//!   - `writeSpk` sends i16 samples to ES8311 via I2S, and when software
//!     ref is active, feeds the same samples into the ref FIFO.
//!   - `setMicGain` programs the ES7210 PGA for a specific channel.
//!   - `setSpkGain` programs the ES8311 DAC volume register; when using
//!     hardware ref, the ref channel PGA is also adjusted automatically.
//!   - Ref-to-mic alignment is handled internally (hw ref is inherently
//!     aligned; sw ref uses a configurable sample delay).

const std = @import("std");
const hal_audio = @import("embed").hal.audio_system;
const embed = @import("embed");
const es7210_drv = embed.pkg.drivers.es7210;
const es8311_drv = embed.pkg.drivers.es8311;
const esp_i2c = @import("../i2c.zig");
const esp_i2s = @import("../i2s.zig");

const max_mics: usize = 4;
const max_frame_samples: usize = 1024;

const I2cSpec = struct {
    pub const Driver = esp_i2c.Driver;
    pub const DeviceHandle = esp_i2c.Driver.DeviceHandle;
    pub const meta = .{ .id = "esp.i2c" };
};

const MicCodec = es7210_drv.Es7210(I2cSpec);
const SpkCodec = es8311_drv.Es8311(I2cSpec);

pub const RefMode = union(enum) {
    /// Ref comes from a designated ES7210 mic channel (hardware loopback).
    /// The channel is determined by whichever mic has `is_ref = true`.
    hw,
    /// Ref comes from speaker write path (software loopback).
    sw: struct {
        delay_samples: usize = 0,
    },
};

/// Per-channel mic configuration.
/// Maps 1:1 to ES7210 PGA gain steps, plus two special values.
pub const MicGain = enum {
    disabled,
    /// AEC reference channel — gain is auto-tracked to speaker volume.
    ref,
    @"0dB",
    @"3dB",
    @"6dB",
    @"9dB",
    @"12dB",
    @"15dB",
    @"18dB",
    @"21dB",
    @"24dB",
    @"27dB",
    @"30dB",
    @"33dB",
    @"36dB",
    @"37.5dB",

    pub fn toEs7210Gain(self: MicGain) ?es7210_drv.Gain {
        return switch (self) {
            .disabled, .ref => null,
            .@"0dB" => .@"0dB",
            .@"3dB" => .@"3dB",
            .@"6dB" => .@"6dB",
            .@"9dB" => .@"9dB",
            .@"12dB" => .@"12dB",
            .@"15dB" => .@"15dB",
            .@"18dB" => .@"18dB",
            .@"21dB" => .@"21dB",
            .@"24dB" => .@"24dB",
            .@"27dB" => .@"27dB",
            .@"30dB" => .@"30dB",
            .@"33dB" => .@"33dB",
            .@"36dB" => .@"36dB",
            .@"37.5dB" => .@"37.5dB",
        };
    }

    pub fn isEnabled(self: MicGain) bool {
        return self != .disabled;
    }

    pub fn isRef(self: MicGain) bool {
        return self == .ref;
    }
};

pub const I2sPins = struct {
    port: u8 = 0,
    mclk: i32 = -1,
    bclk: i32,
    ws: i32,
    din: i32,
    dout: i32,
    dma_desc_num: u16 = 8,
    dma_frame_num: u16 = 320,
    timeout_ms: u32 = 1000,
};

pub const Config = struct {
    mic_codec_address: u7 = es7210_drv.DEFAULT_ADDRESS,
    spk_codec: es8311_drv.Config = .{ .address = @intFromEnum(es8311_drv.Address.ad0_low), .codec_mode = .dac_only },

    i2s: I2sPins,
    sample_rate: u32 = 16_000,

    mics: [max_mics]MicGain = .{ .disabled, .disabled, .disabled, .disabled },
    ref: RefMode = .hw,
    frame_samples: u16 = 160,

    spk_initial_volume: ?u8 = null,

    sw_ref_fifo_cap: usize = 256 * 256,
};

pub const Driver = struct {
    const Self = @This();

    const mic_count = max_mics;
    const FrameType = hal_audio.Frame(mic_count);

    cfg: Config,
    allocator: std.mem.Allocator,

    mic_codec: MicCodec,
    spk_codec: SpkCodec,

    i2c_driver: *esp_i2c.Driver,

    i2s_driver: esp_i2s.Driver,
    rx_handle: esp_i2s.EndpointHandle,
    tx_handle: esp_i2s.EndpointHandle,

    enabled_count: usize,
    hw_ref_slot: ?usize,
    frame_samples: usize,
    slot_to_mic: [max_mics]u8,

    interleaved: [2 * max_frame_samples]i32,
    mic_buffers: [max_mics][max_frame_samples]i16,
    mic_views: [max_mics][]const i16,
    ref_buf: [max_frame_samples]i16,
    pending_bytes: usize,

    // Software ref FIFO (only used when ref == .sw)
    sw_ref_fifo: ?[]i16,
    sw_ref_rd: usize,
    sw_ref_wr: usize,
    sw_ref_count: usize,
    sw_ref_delay_remaining: usize,

    tx_scratch: [max_frame_samples * 2]i32,

    spk_gain_db: i8,

    pub fn init(
        allocator: std.mem.Allocator,
        i2c_driver: *esp_i2c.Driver,
        cfg: Config,
    ) hal_audio.Error!*Self {
        if (cfg.frame_samples == 0 or cfg.frame_samples > max_frame_samples) {
            return error.InvalidState;
        }

        const parsed = parseMicLayout(cfg) catch return error.InvalidState;
        if (parsed.enabled_count == 0) return error.InvalidState;

        // Init codecs first (matching loopback init order: codec → I2S)
        var spk_codec = SpkCodec.init(i2c_driver, cfg.spk_codec);
        spk_codec.open() catch return error.AudioSystemError;
        errdefer spk_codec.close() catch {};
        spk_codec.setSampleRate(cfg.sample_rate) catch return error.AudioSystemError;
        spk_codec.setBitsPerSample(.@"16bit") catch return error.AudioSystemError;
        spk_codec.setFormat(.i2s) catch return error.AudioSystemError;

        if (cfg.spk_initial_volume) |vol| {
            spk_codec.setVolume(vol) catch return error.AudioSystemError;
        }

        const mic_codec_cfg: es7210_drv.Config = .{
            .address = cfg.mic_codec_address,
            .mic_select = parsed.mic_select,
        };

        var mic_codec = MicCodec.init(i2c_driver, mic_codec_cfg);
        mic_codec.open() catch return error.AudioSystemError;
        errdefer mic_codec.close() catch {};
        mic_codec.setSampleRate(cfg.sample_rate) catch return error.AudioSystemError;
        applyInitGains(&mic_codec, parsed) catch return error.AudioSystemError;

        // I2S bus + endpoints (Driver uses duplex automatically when both are registered)
        var i2s_driver = esp_i2s.Driver.initBus(.{
            .port = cfg.i2s.port,
            .role = .master,
            .sample_rate_hz = cfg.sample_rate,
            .bits_per_sample = .bits32,
            .mode = .std,
            .slot_mode = .stereo,
            .tdm_slot_mask = 0,
            .mclk = cfg.i2s.mclk,
            .bclk = cfg.i2s.bclk,
            .ws = cfg.i2s.ws,
            .dma_desc_num = cfg.i2s.dma_desc_num,
            .dma_frame_num = cfg.i2s.dma_frame_num,
        }) catch return error.AudioSystemError;
        errdefer i2s_driver.deinitBus();

        const rx_handle = i2s_driver.registerEndpoint(.{
            .direction = .rx,
            .data_pin = cfg.i2s.din,
            .timeout_ms = cfg.i2s.timeout_ms,
        }) catch return error.AudioSystemError;

        const tx_handle = i2s_driver.registerEndpoint(.{
            .direction = .tx,
            .data_pin = cfg.i2s.dout,
            .timeout_ms = cfg.i2s.timeout_ms,
        }) catch return error.AudioSystemError;

        const sw_fifo: ?[]i16 = switch (cfg.ref) {
            .sw => allocator.alloc(i16, cfg.sw_ref_fifo_cap) catch return error.AudioSystemError,
            .hw => null,
        };
        errdefer if (sw_fifo) |f| allocator.free(f);

        const sw_delay: usize = switch (cfg.ref) {
            .sw => |s| s.delay_samples,
            .hw => 0,
        };

        const self = allocator.create(Self) catch return error.AudioSystemError;
        self.* = .{
            .cfg = cfg,
            .allocator = allocator,
            .mic_codec = mic_codec,
            .spk_codec = spk_codec,
            .i2c_driver = i2c_driver,
            .i2s_driver = i2s_driver,
            .rx_handle = rx_handle,
            .tx_handle = tx_handle,
            .enabled_count = parsed.enabled_count,
            .hw_ref_slot = parsed.hw_ref_slot,
            .frame_samples = cfg.frame_samples,
            .slot_to_mic = parsed.slot_to_mic,
            .interleaved = undefined,
            .mic_buffers = undefined,
            .mic_views = undefined,
            .ref_buf = undefined,
            .pending_bytes = 0,
            .sw_ref_fifo = sw_fifo,
            .sw_ref_rd = 0,
            .sw_ref_wr = 0,
            .sw_ref_count = 0,
            .sw_ref_delay_remaining = sw_delay,
            .tx_scratch = undefined,
            .spk_gain_db = 0,
        };
        for (0..max_mics) |i| self.mic_views[i] = &.{};
        return self;
    }

    pub fn deinit(self: *Self) void {
        self.stop() catch {};
        self.mic_codec.close() catch {};
        self.spk_codec.close() catch {};
        self.i2s_driver.deinitBus();
        if (self.sw_ref_fifo) |f| self.allocator.free(f);
        self.allocator.destroy(self);
    }

    pub fn readFrame(self: *Self) hal_audio.Error!FrameType {
        // STD 32-bit stereo: 2 x i32 per sample frame.
        // ES7210 packs 4x16-bit channels into 2x32-bit slots:
        //   L[31:16]=MIC1, L[15:0]=MIC3, R[31:16]=MIC2, R[15:0]=MIC4
        const stereo_slots = 2;
        const frame_total = self.frame_samples * stereo_slots;
        const frame_bytes = frame_total * @sizeOf(i32);
        const read_buf = std.mem.sliceAsBytes(self.interleaved[0..frame_total]);

        if (self.pending_bytes < frame_bytes) {
            const need = frame_bytes - self.pending_bytes;
            const n = self.i2s_driver.read(self.rx_handle, read_buf[self.pending_bytes .. self.pending_bytes + need]) catch
                return error.AudioSystemError;
            if (n == 0) return error.WouldBlock;
            self.pending_bytes += n;
        }

        if (self.pending_bytes < frame_bytes) return error.WouldBlock;
        self.pending_bytes = 0;

        // Unpack 4x16-bit channels from 2x32-bit STD stereo slots
        for (0..self.frame_samples) |i| {
            const l = self.interleaved[i * 2];
            const r = self.interleaved[i * 2 + 1];
            self.mic_buffers[0][i] = @truncate(l >> 16);
            self.mic_buffers[2][i] = @truncate(l & 0xFFFF);
            self.mic_buffers[1][i] = @truncate(r >> 16);
            self.mic_buffers[3][i] = @truncate(r & 0xFFFF);
        }

        // Build mic views from enabled slots (exclude hw ref slot)
        var view_idx: usize = 0;
        for (0..self.enabled_count) |slot| {
            const mic_ch = self.slot_to_mic[slot];
            if (self.hw_ref_slot != null and slot == self.hw_ref_slot.?) continue;
            self.mic_views[view_idx] = self.mic_buffers[mic_ch][0..self.frame_samples];
            view_idx += 1;
        }
        while (view_idx < max_mics) : (view_idx += 1) {
            self.mic_views[view_idx] = &.{};
        }

        // Build ref
        switch (self.cfg.ref) {
            .hw => {
                const ref_ch = self.slot_to_mic[self.hw_ref_slot.?];
                @memcpy(self.ref_buf[0..self.frame_samples], self.mic_buffers[ref_ch][0..self.frame_samples]);
            },
            .sw => {
                self.drainSwRef(self.ref_buf[0..self.frame_samples]);
            },
        }

        return .{
            .mic = self.mic_views,
            .ref = self.ref_buf[0..self.frame_samples],
        };
    }

    pub fn writeSpk(self: *Self, buffer: []const i16) hal_audio.Error!usize {
        if (buffer.len == 0) return 0;

        // Feed sw ref FIFO before writing to I2S
        if (self.sw_ref_fifo != null) {
            for (buffer) |s| self.swRefPush(s);
        }

        return self.writeStereoDuplicated(buffer);
    }

    pub fn setMicGain(self: *Self, mic_index: u8, gain: MicGain) hal_audio.Error!void {
        if (mic_index >= max_mics) return error.InvalidState;
        const m = self.cfg.mics[mic_index];
        if (!m.isEnabled() or m.isRef()) return error.InvalidState;
        const hw_gain = gain.toEs7210Gain() orelse return error.InvalidState;
        self.mic_codec.setChannelGain(@intCast(mic_index), hw_gain) catch return error.AudioSystemError;
    }

    pub fn setSpkGain(self: *Self, gain_db: i8) hal_audio.Error!void {
        self.spk_gain_db = gain_db;
        const reg_f = (@as(f32, @floatFromInt(gain_db)) + 95.5) * 2.0;
        const clamped = @max(0.0, @min(255.0, reg_f));
        const vol: u8 = @intFromFloat(clamped);
        self.spk_codec.setVolume(vol) catch return error.AudioSystemError;

        if (self.hw_ref_slot) |slot| {
            const ref_ch = self.slot_to_mic[slot];
            const ref_gain = es7210_drv.Gain.fromDb(@as(f32, @floatFromInt(gain_db)));
            self.mic_codec.setChannelGain(@intCast(ref_ch), ref_gain) catch return error.AudioSystemError;
        }
    }

    pub fn start(self: *Self) hal_audio.Error!void {
        self.pending_bytes = 0;
        self.mic_codec.enable(true) catch return error.AudioSystemError;
        self.spk_codec.enable(true) catch return error.AudioSystemError;
    }

    pub fn stop(self: *Self) hal_audio.Error!void {
        self.spk_codec.enable(false) catch {};
        self.mic_codec.enable(false) catch {};
        self.pending_bytes = 0;
    }

    // ── internal ──

    fn writeStereoDuplicated(self: *Self, mono: []const i16) hal_audio.Error!usize {
        var total: usize = 0;

        while (total < mono.len) {
            const chunk = @min(max_frame_samples, mono.len - total);
            for (0..chunk) |i| {
                const wide: i32 = @as(i32, mono[total + i]) << 16;
                self.tx_scratch[i * 2] = wide;
                self.tx_scratch[i * 2 + 1] = wide;
            }

            const frame_bytes = std.mem.sliceAsBytes(self.tx_scratch[0 .. chunk * 2]);
            const written_bytes = self.i2s_driver.write(self.tx_handle, frame_bytes) catch return error.AudioSystemError;
            if (written_bytes == 0) {
                if (total == 0) return error.WouldBlock;
                break;
            }
            const mono_written = written_bytes / @sizeOf(i32) / 2;
            if (mono_written == 0) break;
            total += mono_written;
            if (mono_written < chunk) break;
        }

        return total;
    }

    fn swRefPush(self: *Self, sample: i16) void {
        const fifo = self.sw_ref_fifo.?;
        if (self.sw_ref_count == fifo.len) return;
        fifo[self.sw_ref_wr] = sample;
        self.sw_ref_wr = (self.sw_ref_wr + 1) % fifo.len;
        self.sw_ref_count += 1;
    }

    fn drainSwRef(self: *Self, out: []i16) void {
        for (out) |*o| {
            if (self.sw_ref_delay_remaining > 0) {
                o.* = 0;
                self.sw_ref_delay_remaining -= 1;
                continue;
            }
            if (self.sw_ref_count > 0) {
                o.* = self.sw_ref_fifo.?[self.sw_ref_rd];
                self.sw_ref_rd = (self.sw_ref_rd + 1) % self.sw_ref_fifo.?.len;
                self.sw_ref_count -= 1;
            } else {
                o.* = 0;
            }
        }
    }
};

// ── layout parsing ──

const ParsedLayout = struct {
    mic_select: es7210_drv.MicSelect,
    enabled_count: usize,
    hw_ref_slot: ?usize,
    slot_to_mic: [max_mics]u8,
    gains: [max_mics]?es7210_drv.Gain,
};

fn parseMicLayout(cfg: Config) !ParsedLayout {
    var out = ParsedLayout{
        .mic_select = .{},
        .enabled_count = 0,
        .hw_ref_slot = null,
        .slot_to_mic = .{ 0, 0, 0, 0 },
        .gains = .{ null, null, null, null },
    };

    for (cfg.mics, 0..) |m, mic_idx| {
        if (!m.isEnabled()) continue;

        const slot = out.enabled_count;
        out.slot_to_mic[slot] = @intCast(mic_idx);
        out.gains[slot] = m.toEs7210Gain();

        switch (mic_idx) {
            0 => out.mic_select.mic1 = true,
            1 => out.mic_select.mic2 = true,
            2 => out.mic_select.mic3 = true,
            3 => out.mic_select.mic4 = true,
            else => unreachable,
        }

        if (m.isRef()) out.hw_ref_slot = slot;

        out.enabled_count += 1;
    }

    return out;
}

fn applyInitGains(codec: *MicCodec, layout: ParsedLayout) !void {
    var slot: usize = 0;
    while (slot < layout.enabled_count) : (slot += 1) {
        if (layout.gains[slot]) |gain| {
            codec.setChannelGain(@intCast(layout.slot_to_mic[slot]), gain) catch return error.AudioSystemError;
        }
    }
}

fn mapError(err: anyerror) hal_audio.Error {
    return switch (err) {
        error.Timeout => error.Timeout,
        error.InvalidParam, error.InvalidDirection => error.InvalidState,
        else => error.AudioSystemError,
    };
}

test {
    _ = hal_audio.from(struct {
        pub const Driver = @import("es7210_es8311.zig").Driver;
        pub const meta = .{ .id = "test.es7210_es8311" };
        pub const config = hal_audio.Config{ .sample_rate = 16000, .mic_count = 4 };
    });
}
