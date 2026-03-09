const i2s = @import("../component/esp_driver_i2s/i2s.zig");
const hal_i2s = @import("embed").hal.i2s;

pub const EndpointHandle = enum(u8) {
    rx = 1,
    tx = 2,
};

pub const DriverType = Driver;
pub const DeviceHandle = EndpointHandle;

pub const Driver = struct {
    cfg: hal_i2s.BusConfig,

    // Pending endpoint configs (before hardware init)
    rx_pin: ?i32 = null,
    tx_pin: ?i32 = null,
    rx_timeout_ms: u32 = 20,
    tx_timeout_ms: u32 = 20,

    // Live hardware handles (after init)
    duplex: ?i2s.I2sDuplex = null,
    simplex_rx: ?i2s.I2sRx = null,
    simplex_tx: ?i2s.I2sTx = null,
    initialized: bool = false,

    pub fn initBus(cfg: hal_i2s.BusConfig) hal_i2s.Error!Driver {
        if (cfg.sample_rate_hz == 0) return error.InvalidParam;
        if (cfg.mode == .std and cfg.tdm_slot_mask != 0) return error.InvalidParam;
        if (cfg.mode == .tdm and cfg.tdm_slot_mask == 0) return error.InvalidParam;
        return .{ .cfg = cfg };
    }

    pub fn deinitBus(self: *Driver) void {
        if (self.duplex) |d| {
            d.deinit() catch {};
            self.duplex = null;
        }
        if (self.simplex_rx) |rx| {
            rx.deinit() catch {};
            self.simplex_rx = null;
        }
        if (self.simplex_tx) |tx| {
            tx.deinit() catch {};
            self.simplex_tx = null;
        }
        self.rx_pin = null;
        self.tx_pin = null;
        self.initialized = false;
    }

    pub fn registerEndpoint(self: *Driver, ep: hal_i2s.EndpointConfig) hal_i2s.Error!EndpointHandle {
        if (self.initialized) return error.Busy;

        switch (ep.direction) {
            .rx => {
                if (self.rx_pin != null) return error.Busy;
                self.rx_pin = ep.data_pin;
                self.rx_timeout_ms = ep.timeout_ms;
                return .rx;
            },
            .tx => {
                if (self.tx_pin != null) return error.Busy;
                self.tx_pin = ep.data_pin;
                self.tx_timeout_ms = ep.timeout_ms;
                return .tx;
            },
        }
    }

    pub fn unregisterEndpoint(self: *Driver, handle: EndpointHandle) hal_i2s.Error!void {
        switch (handle) {
            .rx => {
                if (self.rx_pin == null) return error.InvalidParam;
                if (self.initialized) {
                    if (self.duplex) |d| {
                        d.deinit() catch {};
                        self.duplex = null;
                    } else if (self.simplex_rx) |rx| {
                        rx.deinit() catch {};
                        self.simplex_rx = null;
                    }
                    self.initialized = false;
                }
                self.rx_pin = null;
            },
            .tx => {
                if (self.tx_pin == null) return error.InvalidParam;
                if (self.initialized) {
                    if (self.duplex) |d| {
                        d.deinit() catch {};
                        self.duplex = null;
                    } else if (self.simplex_tx) |tx| {
                        tx.deinit() catch {};
                        self.simplex_tx = null;
                    }
                    self.initialized = false;
                }
                self.tx_pin = null;
            },
        }
    }

    /// Lazily initialize hardware on first I/O.
    /// Uses duplex when both RX and TX are registered, simplex otherwise.
    fn ensureInit(self: *Driver) hal_i2s.Error!void {
        if (self.initialized) return;

        const has_rx = self.rx_pin != null;
        const has_tx = self.tx_pin != null;

        if (!has_rx and !has_tx) return error.InvalidParam;

        if (has_rx and has_tx) {
            const d = i2s.I2sDuplex.init(.{
                .port = self.cfg.port,
                .role = mapRole(self.cfg.role),
                .rx = .{
                    .sample_rate_hz = self.cfg.sample_rate_hz,
                    .bits_per_sample = mapBits(self.cfg.bits_per_sample),
                    .mode = mapMode(self.cfg.mode),
                    .slot_mode = mapSlot(self.cfg.slot_mode),
                    .tdm_slot_mask = self.cfg.tdm_slot_mask,
                    .mclk = self.cfg.mclk,
                    .bclk = self.cfg.bclk,
                    .ws = self.cfg.ws,
                    .din = self.rx_pin.?,
                    .dma_desc_num = self.cfg.dma_desc_num,
                    .dma_frame_num = self.cfg.dma_frame_num,
                },
                .tx = .{
                    .sample_rate_hz = self.cfg.sample_rate_hz,
                    .bits_per_sample = mapBits(self.cfg.bits_per_sample),
                    .mode = mapMode(self.cfg.mode),
                    .slot_mode = mapSlot(self.cfg.slot_mode),
                    .tdm_slot_mask = self.cfg.tdm_slot_mask,
                    .mclk = self.cfg.mclk,
                    .bclk = self.cfg.bclk,
                    .ws = self.cfg.ws,
                    .dout = self.tx_pin.?,
                    .dma_desc_num = self.cfg.dma_desc_num,
                    .dma_frame_num = self.cfg.dma_frame_num,
                },
            }) catch |err| return mapEspError(err);
            self.duplex = d;
        } else if (has_rx) {
            const rx = i2s.I2sRx.init(.{
                .port = self.cfg.port,
                .role = mapRole(self.cfg.role),
                .sample_rate_hz = self.cfg.sample_rate_hz,
                .bits_per_sample = mapBits(self.cfg.bits_per_sample),
                .mode = mapMode(self.cfg.mode),
                .slot_mode = mapSlot(self.cfg.slot_mode),
                .tdm_slot_mask = self.cfg.tdm_slot_mask,
                .mclk = self.cfg.mclk,
                .bclk = self.cfg.bclk,
                .ws = self.cfg.ws,
                .din = self.rx_pin.?,
                .dma_desc_num = self.cfg.dma_desc_num,
                .dma_frame_num = self.cfg.dma_frame_num,
            }) catch |err| return mapEspError(err);
            self.simplex_rx = rx;
        } else {
            const tx = i2s.I2sTx.init(.{
                .port = self.cfg.port,
                .role = mapRole(self.cfg.role),
                .sample_rate_hz = self.cfg.sample_rate_hz,
                .bits_per_sample = mapBits(self.cfg.bits_per_sample),
                .mode = mapMode(self.cfg.mode),
                .slot_mode = mapSlot(self.cfg.slot_mode),
                .tdm_slot_mask = self.cfg.tdm_slot_mask,
                .mclk = self.cfg.mclk,
                .bclk = self.cfg.bclk,
                .ws = self.cfg.ws,
                .dout = self.tx_pin.?,
                .dma_desc_num = self.cfg.dma_desc_num,
                .dma_frame_num = self.cfg.dma_frame_num,
            }) catch |err| return mapEspError(err);
            self.simplex_tx = tx;
        }

        self.initialized = true;
    }

    pub fn read(self: *Driver, handle: EndpointHandle, out: []u8) hal_i2s.Error!usize {
        if (handle != .rx) return error.InvalidDirection;
        if (self.rx_pin == null) return error.InvalidParam;
        try self.ensureInit();
        if (self.duplex) |d| {
            return d.read(out, self.rx_timeout_ms) catch |err| return mapEspError(err);
        }
        const rx = self.simplex_rx orelse return error.InvalidParam;
        return rx.read(out, self.rx_timeout_ms) catch |err| return mapEspError(err);
    }

    pub fn write(self: *Driver, handle: EndpointHandle, input: []const u8) hal_i2s.Error!usize {
        if (handle != .tx) return error.InvalidDirection;
        if (self.tx_pin == null) return error.InvalidParam;
        try self.ensureInit();
        if (self.duplex) |d| {
            return d.write(input, self.tx_timeout_ms) catch |err| return mapEspError(err);
        }
        const tx = self.simplex_tx orelse return error.InvalidParam;
        return tx.write(input, self.tx_timeout_ms) catch |err| return mapEspError(err);
    }
};

fn mapRole(role: hal_i2s.Role) i2s.Role {
    return switch (role) {
        .master => .master,
        .slave => .slave,
    };
}

fn mapMode(mode: hal_i2s.Mode) i2s.ChannelMode {
    return switch (mode) {
        .std => .std,
        .tdm => .tdm,
    };
}

fn mapSlot(slot: hal_i2s.SlotMode) i2s.SlotMode {
    return switch (slot) {
        .mono => .mono,
        .stereo => .stereo,
    };
}

fn mapBits(bits: hal_i2s.BitsPerSample) i2s.BitsPerSample {
    return switch (bits) {
        .bits16 => .bits16,
        .bits24 => .bits24,
        .bits32 => .bits32,
    };
}

fn mapEspError(err: anyerror) hal_i2s.Error {
    return switch (err) {
        error.Timeout => error.Timeout,
        error.InvalidArg, error.InvalidState, error.InvalidSize => error.InvalidParam,
        error.NotSupported => error.InvalidParam,
        else => error.I2sError,
    };
}
