const std = @import("std");

pub const EspError = i32;
pub const esp_ok: EspError = 0;

const esp_err_no_mem: EspError = 0x101;
const esp_err_invalid_arg: EspError = 0x102;
const esp_err_invalid_state: EspError = 0x103;
const esp_err_not_found: EspError = 0x105;
const esp_err_invalid_size: EspError = 0x106;

pub const Error = error{
    NotInitialized,
    AlreadyInitialized,
    InvalidState,
    InvalidArgument,
    OutOfMemory,
    NotFound,
    BufferTooSmall,
    EspIdfFailure,
};

const CStaConfig = extern struct {
    ssid: ?[*]const u8,
    ssid_len: u8,
    password: ?[*]const u8,
    password_len: u8,
    listen_interval: u16,
};

const CApConfig = extern struct {
    ssid: ?[*]const u8,
    ssid_len: u8,
    password: ?[*]const u8,
    password_len: u8,
    channel: u8,
    max_connection: u8,
    hidden: bool,
};

pub const CScanConfig = extern struct {
    channel: u8,
    show_hidden: bool,
    block_until_done: bool,
    max_results: u16,
};

pub const CScanRecord = extern struct {
    ssid: [32]u8,
    rssi: i8,
    channel: u8,
    authmode: u8,
};

const CIpConfig = extern struct {
    ip: [4]u8,
    gateway: [4]u8,
    netmask: [4]u8,
    has_dns1: bool,
    dns1: [4]u8,
    has_dns2: bool,
    dns2: [4]u8,
};

extern fn espz_wifi_runtime_init() EspError;
extern fn espz_wifi_runtime_deinit() EspError;

extern fn espz_wifi_set_mode(mode: u8) EspError;
extern fn espz_wifi_start() EspError;
extern fn espz_wifi_stop() EspError;
extern fn espz_wifi_connect() EspError;
extern fn espz_wifi_disconnect() EspError;

extern fn espz_wifi_set_sta_config(cfg: *const CStaConfig) EspError;
extern fn espz_wifi_set_ap_config(cfg: *const CApConfig) EspError;

pub extern fn espz_wifi_scan(
    cfg: *const CScanConfig,
    out_records: [*]CScanRecord,
    out_cap: u16,
    out_count: *u16,
) EspError;

extern fn espz_wifi_set_hostname(hostname: [*]const u8, hostname_len: u8) EspError;
extern fn espz_wifi_use_dhcp_sta() EspError;
extern fn espz_wifi_use_static_ip_sta(cfg: *const CIpConfig) EspError;

extern fn espz_wifi_get_sta_ip(out: *CIpConfig) EspError;
extern fn espz_wifi_get_sta_mac(out: *[6]u8) EspError;

extern fn espz_wifi_set_power_save(ps: u8) EspError;
extern fn espz_wifi_get_power_save(out_ps: *u8) EspError;
extern fn espz_wifi_set_max_tx_power(quarter_dbm: i8) EspError;

extern fn espz_wifi_set_protocol_mask(mode: u8, mask: u8) EspError;
extern fn espz_wifi_set_bandwidth(mode: u8, bw: u8) EspError;
extern fn espz_wifi_set_channel(primary: u8, second: u8) EspError;

pub const WiFi = struct {
    pub const Mode = enum(u8) {
        sta = 1,
        ap = 2,
        apsta = 3,
    };

    pub const PowerSave = enum(u8) {
        none = 0,
        min_modem = 1,
        max_modem = 2,
    };

    pub const Bandwidth = enum(u8) {
        ht20 = 0,
        ht40 = 1,
    };

    pub const StaConfig = struct {
        ssid: []const u8,
        password: []const u8 = "",
        listen_interval: u16 = 0,
    };

    pub const ApConfig = struct {
        ssid: []const u8,
        password: []const u8 = "",
        channel: u8 = 6,
        max_connection: u8 = 4,
        hidden: bool = false,
    };

    pub const ScanConfig = struct {
        channel: u8 = 0,
        show_hidden: bool = false,
        block_until_done: bool = true,
        max_results: u16 = 12,
    };

    pub const ScanRecord = struct {
        ssid: [32]u8,
        rssi: i8,
        channel: u8,
        authmode: u8,
    };

    pub const IpConfig = struct {
        ip: [4]u8,
        gateway: [4]u8,
        netmask: [4]u8,
        dns1: ?[4]u8 = null,
        dns2: ?[4]u8 = null,
    };

    initialized: bool = false,
    started: bool = false,
    mode: ?Mode = null,

    pub fn init() Error!WiFi {
        try check(espz_wifi_runtime_init());
        return .{ .initialized = true };
    }

    pub fn deinit(self: *WiFi) Error!void {
        try self.requireInitialized();
        if (self.started) {
            try self.stop();
        }
        try check(espz_wifi_runtime_deinit());
        self.* = .{};
    }

    pub fn start(self: *WiFi) Error!void {
        try self.requireInitialized();
        if (self.started) return;
        try check(espz_wifi_start());
        self.started = true;
    }

    pub fn stop(self: *WiFi) Error!void {
        try self.requireInitialized();
        if (!self.started) return;
        try check(espz_wifi_stop());
        self.started = false;
    }

    pub fn setMode(self: *WiFi, mode: Mode) Error!void {
        try self.requireInitialized();
        try check(espz_wifi_set_mode(@intFromEnum(mode)));
        self.mode = mode;
    }

    pub fn startSta(self: *WiFi, cfg: StaConfig) Error!void {
        try self.setMode(.sta);
        try self.configureSta(cfg);
        try self.start();
    }

    pub fn configureSta(self: *WiFi, cfg: StaConfig) Error!void {
        try self.requireInitialized();
        try validateStaConfig(cfg);

        const c_cfg: CStaConfig = .{
            .ssid = cfg.ssid.ptr,
            .ssid_len = @intCast(cfg.ssid.len),
            .password = if (cfg.password.len == 0) null else cfg.password.ptr,
            .password_len = @intCast(cfg.password.len),
            .listen_interval = cfg.listen_interval,
        };
        try check(espz_wifi_set_sta_config(&c_cfg));
    }

    pub fn connectSta(self: *WiFi) Error!void {
        try self.requireInitialized();
        if (self.mode != .sta and self.mode != .apsta) {
            return error.InvalidState;
        }
        try check(espz_wifi_connect());
    }

    pub fn disconnectSta(self: *WiFi) Error!void {
        try self.requireInitialized();
        try check(espz_wifi_disconnect());
    }

    pub fn startAp(self: *WiFi, cfg: ApConfig) Error!void {
        try self.setMode(.ap);
        try self.configureAp(cfg);
        try self.start();
    }

    pub fn configureAp(self: *WiFi, cfg: ApConfig) Error!void {
        try self.requireInitialized();
        try validateApConfig(cfg);

        const c_cfg: CApConfig = .{
            .ssid = cfg.ssid.ptr,
            .ssid_len = @intCast(cfg.ssid.len),
            .password = if (cfg.password.len == 0) null else cfg.password.ptr,
            .password_len = @intCast(cfg.password.len),
            .channel = cfg.channel,
            .max_connection = cfg.max_connection,
            .hidden = cfg.hidden,
        };
        try check(espz_wifi_set_ap_config(&c_cfg));
    }

    pub fn stopAp(self: *WiFi) Error!void {
        try self.stop();
    }

    pub fn scan(self: *WiFi, cfg: ScanConfig, allocator: std.mem.Allocator) Error![]ScanRecord {
        try self.requireInitialized();
        const cap: u16 = if (cfg.max_results == 0) 1 else cfg.max_results;

        const c_cfg: CScanConfig = .{
            .channel = cfg.channel,
            .show_hidden = cfg.show_hidden,
            .block_until_done = cfg.block_until_done,
            .max_results = cap,
        };

        const tmp_records = try allocator.alloc(CScanRecord, cap);
        defer allocator.free(tmp_records);

        var out_count: u16 = 0;
        try check(espz_wifi_scan(&c_cfg, tmp_records.ptr, cap, &out_count));

        const count: usize = out_count;
        const records = try allocator.alloc(ScanRecord, count);
        errdefer allocator.free(records);

        for (records, 0..) |*item, idx| {
            item.* = .{
                .ssid = tmp_records[idx].ssid,
                .rssi = tmp_records[idx].rssi,
                .channel = tmp_records[idx].channel,
                .authmode = tmp_records[idx].authmode,
            };
        }
        return records;
    }

    pub fn getStaIp(self: *WiFi) Error!IpConfig {
        try self.requireInitialized();
        var c_cfg: CIpConfig = undefined;
        try check(espz_wifi_get_sta_ip(&c_cfg));
        return .{
            .ip = c_cfg.ip,
            .gateway = c_cfg.gateway,
            .netmask = c_cfg.netmask,
            .dns1 = if (c_cfg.has_dns1) c_cfg.dns1 else null,
            .dns2 = if (c_cfg.has_dns2) c_cfg.dns2 else null,
        };
    }

    pub fn getStaMac(self: *WiFi) Error![6]u8 {
        try self.requireInitialized();
        var mac: [6]u8 = undefined;
        try check(espz_wifi_get_sta_mac(&mac));
        return mac;
    }

    pub fn setHostname(self: *WiFi, hostname: []const u8) Error!void {
        try self.requireInitialized();
        try validateHostname(hostname);
        try check(espz_wifi_set_hostname(hostname.ptr, @intCast(hostname.len)));
    }

    pub fn useDhcpSta(self: *WiFi) Error!void {
        try self.requireInitialized();
        try check(espz_wifi_use_dhcp_sta());
    }

    pub fn useStaticIpSta(self: *WiFi, cfg: IpConfig) Error!void {
        try self.requireInitialized();

        const zero4 = [_]u8{ 0, 0, 0, 0 };
        const c_cfg: CIpConfig = .{
            .ip = cfg.ip,
            .gateway = cfg.gateway,
            .netmask = cfg.netmask,
            .has_dns1 = cfg.dns1 != null,
            .dns1 = cfg.dns1 orelse zero4,
            .has_dns2 = cfg.dns2 != null,
            .dns2 = cfg.dns2 orelse zero4,
        };

        try check(espz_wifi_use_static_ip_sta(&c_cfg));
    }

    pub fn setPowerSave(self: *WiFi, ps: PowerSave) Error!void {
        try self.requireInitialized();
        try check(espz_wifi_set_power_save(@intFromEnum(ps)));
    }

    pub fn getPowerSave(self: *WiFi) Error!PowerSave {
        try self.requireInitialized();
        var ps: u8 = 0;
        try check(espz_wifi_get_power_save(&ps));
        return std.meta.intToEnum(PowerSave, ps) catch error.EspIdfFailure;
    }

    pub fn setMaxTxPower(self: *WiFi, quarter_dbm: i8) Error!void {
        try self.requireInitialized();
        try check(espz_wifi_set_max_tx_power(quarter_dbm));
    }

    pub fn setProtocolMask(self: *WiFi, mode: Mode, mask: u8) Error!void {
        try self.requireInitialized();
        if (mode == .apsta) return error.InvalidArgument;
        try check(espz_wifi_set_protocol_mask(@intFromEnum(mode), mask));
    }

    pub fn setBandwidth(self: *WiFi, mode: Mode, bw: Bandwidth) Error!void {
        try self.requireInitialized();
        if (mode == .apsta) return error.InvalidArgument;
        try check(espz_wifi_set_bandwidth(@intFromEnum(mode), @intFromEnum(bw)));
    }

    pub fn setChannel(self: *WiFi, primary: u8, second: u8) Error!void {
        try self.requireInitialized();
        if (primary == 0 or primary > 14) return error.InvalidArgument;
        if (second > 2) return error.InvalidArgument;
        try check(espz_wifi_set_channel(primary, second));
    }

    fn requireInitialized(self: *const WiFi) Error!void {
        if (!self.initialized) return error.NotInitialized;
    }
};

fn check(result: EspError) Error!void {
    switch (result) {
        esp_ok => return,
        esp_err_no_mem => return error.OutOfMemory,
        esp_err_invalid_arg => return error.InvalidArgument,
        esp_err_invalid_state => return error.InvalidState,
        esp_err_not_found => return error.NotFound,
        esp_err_invalid_size => return error.BufferTooSmall,
        else => return error.EspIdfFailure,
    }
}

fn validateStaConfig(cfg: WiFi.StaConfig) Error!void {
    if (cfg.ssid.len == 0 or cfg.ssid.len > 32) return error.InvalidArgument;
    if (cfg.password.len > 64) return error.InvalidArgument;
    if (cfg.password.len > 0 and cfg.password.len < 8) return error.InvalidArgument;
}

fn validateApConfig(cfg: WiFi.ApConfig) Error!void {
    if (cfg.ssid.len == 0 or cfg.ssid.len > 32) return error.InvalidArgument;
    if (cfg.password.len > 63) return error.InvalidArgument;
    if (cfg.password.len > 0 and cfg.password.len < 8) return error.InvalidArgument;
    if (cfg.channel > 14) return error.InvalidArgument;
    if (cfg.max_connection == 0) return error.InvalidArgument;
}

fn validateHostname(hostname: []const u8) Error!void {
    if (hostname.len == 0 or hostname.len > 63) return error.InvalidArgument;
    if (std.mem.indexOfScalar(u8, hostname, 0) != null) return error.InvalidArgument;
}

test "check maps common esp-idf error codes" {
    try check(esp_ok);
    try std.testing.expectError(error.OutOfMemory, check(esp_err_no_mem));
    try std.testing.expectError(error.InvalidArgument, check(esp_err_invalid_arg));
    try std.testing.expectError(error.InvalidState, check(esp_err_invalid_state));
    try std.testing.expectError(error.NotFound, check(esp_err_not_found));
    try std.testing.expectError(error.BufferTooSmall, check(esp_err_invalid_size));
}

test "validateStaConfig enforces ssid and password constraints" {
    try validateStaConfig(.{ .ssid = "ssid", .password = "password" });
    try std.testing.expectError(error.InvalidArgument, validateStaConfig(.{ .ssid = "", .password = "password" }));
    try std.testing.expectError(error.InvalidArgument, validateStaConfig(.{ .ssid = "ok", .password = "short" }));
}

test "validateApConfig enforces range and password policy" {
    try validateApConfig(.{ .ssid = "espz-ap", .password = "", .channel = 6, .max_connection = 4 });
    try std.testing.expectError(error.InvalidArgument, validateApConfig(.{ .ssid = "", .password = "", .channel = 6, .max_connection = 4 }));
    try std.testing.expectError(error.InvalidArgument, validateApConfig(.{ .ssid = "espz-ap", .password = "short", .channel = 6, .max_connection = 4 }));
    try std.testing.expectError(error.InvalidArgument, validateApConfig(.{ .ssid = "espz-ap", .password = "", .channel = 15, .max_connection = 4 }));
    try std.testing.expectError(error.InvalidArgument, validateApConfig(.{ .ssid = "espz-ap", .password = "", .channel = 6, .max_connection = 0 }));
}

test "validateHostname enforces length and nul-free" {
    try validateHostname("espz-device");
    try std.testing.expectError(error.InvalidArgument, validateHostname(""));

    const with_nul = [_]u8{ 'a', 0, 'b' };
    try std.testing.expectError(error.InvalidArgument, validateHostname(&with_nul));
}
