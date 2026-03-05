const std = @import("std");
const esp_error = @import("utils").esp_error;

pub const EspError = esp_error.EspError;
pub const Error = esp_error.Error;
const check = esp_error.check;

pub const Role = enum(i32) {
    master = 0,
    slave = 1,
};

pub const BitsPerSample = enum(u32) {
    bits16 = 16,
    bits24 = 24,
    bits32 = 32,
};

pub const SlotMode = enum(u32) {
    mono = 1,
    stereo = 2,
};

pub const ChannelMode = enum(u32) {
    std = 0,
    tdm = 1,
};

// ── Per-direction configs ──

pub const RxConfig = struct {
    port: i32 = 0,
    role: Role = .master,
    sample_rate_hz: u32 = 16_000,
    bits_per_sample: BitsPerSample = .bits16,
    mode: ChannelMode = .std,
    slot_mode: SlotMode = .mono,
    /// Bit mask for TDM slots (only used when `mode == .tdm`).
    /// Bit i enables slot i, e.g. 0b0011 for slots 0+1.
    tdm_slot_mask: u32 = 0,
    mclk: i32 = -1,
    bclk: i32,
    ws: i32,
    din: i32,
    dma_desc_num: u32 = 6,
    dma_frame_num: u32 = 240,
};

pub const TxConfig = struct {
    port: i32 = 0,
    role: Role = .master,
    sample_rate_hz: u32 = 16_000,
    bits_per_sample: BitsPerSample = .bits16,
    mode: ChannelMode = .std,
    slot_mode: SlotMode = .mono,
    tdm_slot_mask: u32 = 0,
    mclk: i32 = -1,
    bclk: i32,
    ws: i32,
    dout: i32,
    dma_desc_num: u32 = 6,
    dma_frame_num: u32 = 240,
};

pub const DuplexConfig = struct {
    port: i32 = 0,
    role: Role = .master,
    rx: struct {
        sample_rate_hz: u32 = 16_000,
        bits_per_sample: BitsPerSample = .bits16,
        mode: ChannelMode = .std,
        slot_mode: SlotMode = .mono,
        tdm_slot_mask: u32 = 0,
        mclk: i32 = -1,
        bclk: i32,
        ws: i32,
        din: i32,
        dma_desc_num: u32 = 6,
        dma_frame_num: u32 = 240,
    },
    tx: struct {
        sample_rate_hz: u32 = 16_000,
        bits_per_sample: BitsPerSample = .bits16,
        mode: ChannelMode = .std,
        slot_mode: SlotMode = .mono,
        tdm_slot_mask: u32 = 0,
        mclk: i32 = -1,
        bclk: i32,
        ws: i32,
        dout: i32,
        dma_desc_num: u32 = 6,
        dma_frame_num: u32 = 240,
    },
};

// ── Extern declarations ──

extern fn espz_i2s_rx_init(
    port: i32,
    role: i32,
    sample_rate: u32,
    bits: u32,
    mode_tdm: u32,
    slot_mode: u32,
    tdm_mask: u32,
    mclk: i32,
    bclk: i32,
    ws: i32,
    din: i32,
    dma_desc_num: u32,
    dma_frame_num: u32,
) EspError;
extern fn espz_i2s_rx_deinit(port: i32) EspError;
extern fn espz_i2s_rx_read(port: i32, out: [*]u8, len: usize, timeout_ms: u32, out_bytes: *usize) EspError;

extern fn espz_i2s_tx_init(
    port: i32,
    role: i32,
    sample_rate: u32,
    bits: u32,
    mode_tdm: u32,
    slot_mode: u32,
    tdm_mask: u32,
    mclk: i32,
    bclk: i32,
    ws: i32,
    dout: i32,
    dma_desc_num: u32,
    dma_frame_num: u32,
) EspError;
extern fn espz_i2s_tx_deinit(port: i32) EspError;
extern fn espz_i2s_tx_write(port: i32, in: [*]const u8, len: usize, timeout_ms: u32, out_bytes: *usize) EspError;

extern fn espz_i2s_duplex_init(
    port: i32,
    role: i32,
    rx_sample_rate: u32,
    rx_bits: u32,
    rx_mode_tdm: u32,
    rx_slot_mode: u32,
    rx_tdm_mask: u32,
    rx_mclk: i32,
    rx_bclk: i32,
    rx_ws: i32,
    rx_din: i32,
    rx_dma_desc_num: u32,
    rx_dma_frame_num: u32,
    tx_sample_rate: u32,
    tx_bits: u32,
    tx_mode_tdm: u32,
    tx_slot_mode: u32,
    tx_tdm_mask: u32,
    tx_mclk: i32,
    tx_bclk: i32,
    tx_ws: i32,
    tx_dout: i32,
    tx_dma_desc_num: u32,
    tx_dma_frame_num: u32,
) EspError;
extern fn espz_i2s_duplex_deinit(port: i32) EspError;

// ── I2sRx (simplex receive) ──

pub const I2sRx = struct {
    port: i32,

    pub fn init(cfg: RxConfig) Error!I2sRx {
        try check(espz_i2s_rx_init(
            cfg.port,
            @intFromEnum(cfg.role),
            cfg.sample_rate_hz,
            @intFromEnum(cfg.bits_per_sample),
            @intFromEnum(cfg.mode),
            @intFromEnum(cfg.slot_mode),
            cfg.tdm_slot_mask,
            cfg.mclk,
            cfg.bclk,
            cfg.ws,
            cfg.din,
            cfg.dma_desc_num,
            cfg.dma_frame_num,
        ));
        return .{ .port = cfg.port };
    }

    pub fn deinit(self: I2sRx) Error!void {
        try check(espz_i2s_rx_deinit(self.port));
    }

    pub fn read(self: I2sRx, out: []u8, timeout_ms: u32) Error!usize {
        if (out.len == 0) return 0;
        var n: usize = 0;
        try check(espz_i2s_rx_read(self.port, out.ptr, out.len, timeout_ms, &n));
        return n;
    }

    pub fn readI16(self: I2sRx, out: []i16, timeout_ms: u32) Error!usize {
        const bytes = std.mem.sliceAsBytes(out);
        const n = try self.read(bytes, timeout_ms);
        return n / @sizeOf(i16);
    }
};

// ── I2sTx (simplex transmit) ──

pub const I2sTx = struct {
    port: i32,

    pub fn init(cfg: TxConfig) Error!I2sTx {
        try check(espz_i2s_tx_init(
            cfg.port,
            @intFromEnum(cfg.role),
            cfg.sample_rate_hz,
            @intFromEnum(cfg.bits_per_sample),
            @intFromEnum(cfg.mode),
            @intFromEnum(cfg.slot_mode),
            cfg.tdm_slot_mask,
            cfg.mclk,
            cfg.bclk,
            cfg.ws,
            cfg.dout,
            cfg.dma_desc_num,
            cfg.dma_frame_num,
        ));
        return .{ .port = cfg.port };
    }

    pub fn deinit(self: I2sTx) Error!void {
        try check(espz_i2s_tx_deinit(self.port));
    }

    pub fn write(self: I2sTx, data: []const u8, timeout_ms: u32) Error!usize {
        if (data.len == 0) return 0;
        var n: usize = 0;
        try check(espz_i2s_tx_write(self.port, data.ptr, data.len, timeout_ms, &n));
        return n;
    }

    pub fn writeI16(self: I2sTx, data: []const i16, timeout_ms: u32) Error!usize {
        const bytes = std.mem.sliceAsBytes(data);
        const n = try self.write(bytes, timeout_ms);
        return n / @sizeOf(i16);
    }
};

// ── I2sDuplex (full-duplex RX+TX on the same port) ──

pub const I2sDuplex = struct {
    port: i32,

    /// Allocate both RX and TX channels on the same I2S port in a single call,
    /// so they share BCLK/WS clocks for true full-duplex operation.
    pub fn init(cfg: DuplexConfig) Error!I2sDuplex {
        try check(espz_i2s_duplex_init(
            cfg.port,
            @intFromEnum(cfg.role),
            cfg.rx.sample_rate_hz,
            @intFromEnum(cfg.rx.bits_per_sample),
            @intFromEnum(cfg.rx.mode),
            @intFromEnum(cfg.rx.slot_mode),
            cfg.rx.tdm_slot_mask,
            cfg.rx.mclk,
            cfg.rx.bclk,
            cfg.rx.ws,
            cfg.rx.din,
            cfg.rx.dma_desc_num,
            cfg.rx.dma_frame_num,
            cfg.tx.sample_rate_hz,
            @intFromEnum(cfg.tx.bits_per_sample),
            @intFromEnum(cfg.tx.mode),
            @intFromEnum(cfg.tx.slot_mode),
            cfg.tx.tdm_slot_mask,
            cfg.tx.mclk,
            cfg.tx.bclk,
            cfg.tx.ws,
            cfg.tx.dout,
            cfg.tx.dma_desc_num,
            cfg.tx.dma_frame_num,
        ));
        return .{ .port = cfg.port };
    }

    pub fn deinit(self: I2sDuplex) Error!void {
        try check(espz_i2s_duplex_deinit(self.port));
    }

    pub fn read(self: I2sDuplex, out: []u8, timeout_ms: u32) Error!usize {
        if (out.len == 0) return 0;
        var n: usize = 0;
        try check(espz_i2s_rx_read(self.port, out.ptr, out.len, timeout_ms, &n));
        return n;
    }

    pub fn readI16(self: I2sDuplex, out: []i16, timeout_ms: u32) Error!usize {
        const bytes = std.mem.sliceAsBytes(out);
        const n = try self.read(bytes, timeout_ms);
        return n / @sizeOf(i16);
    }

    pub fn write(self: I2sDuplex, data: []const u8, timeout_ms: u32) Error!usize {
        if (data.len == 0) return 0;
        var n: usize = 0;
        try check(espz_i2s_tx_write(self.port, data.ptr, data.len, timeout_ms, &n));
        return n;
    }

    pub fn writeI16(self: I2sDuplex, data: []const i16, timeout_ms: u32) Error!usize {
        const bytes = std.mem.sliceAsBytes(data);
        const n = try self.write(bytes, timeout_ms);
        return n / @sizeOf(i16);
    }
};
