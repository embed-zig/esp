# wifi package

对应 ESP-IDF component：`esp_wifi`

## 对外接口约束

这个包对外只暴露一个 Zig 结构：`WiFi`。

- 外部代码只通过 `WiFi` 的方法操作 Wi-Fi。
- 不直接调用 `runtime_*.c`。
- 不直接拼装 ESP-IDF 的 Wi-Fi 生命周期细节。

## `WiFi` 结构（设计草案）

```zig
pub const WiFi = struct {
    pub const Mode = enum { sta, ap, apsta };

    pub const PowerSave = enum {
        none,
        min_modem,
        max_modem,
    };

    pub const Bandwidth = enum {
        ht20,
        ht40,
    };

    pub const StaConfig = struct {
        ssid: []const u8,
        password: []const u8,
    };

    pub const ApConfig = struct {
        ssid: []const u8,
        password: []const u8 = "",
        channel: u8 = 6,
        max_connection: u8 = 4,
    };

    pub const ScanConfig = struct {
        channel: u8 = 0,
        show_limit: u16 = 12,
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

    pub fn init() !WiFi {}
    pub fn deinit(self: *WiFi) !void {}
    pub fn start(self: *WiFi) !void {}
    pub fn stop(self: *WiFi) !void {}

    pub fn startSta(self: *WiFi, cfg: StaConfig) !void {}
    pub fn connectSta(self: *WiFi) !void {}
    pub fn disconnectSta(self: *WiFi) !void {}

    pub fn startAp(self: *WiFi, cfg: ApConfig) !void {}
    pub fn stopAp(self: *WiFi) !void {}

    pub fn scan(self: *WiFi, cfg: ScanConfig, allocator: std.mem.Allocator) ![]ScanRecord {}

    pub fn setHostname(self: *WiFi, hostname: []const u8) !void {}
    pub fn useDhcpSta(self: *WiFi) !void {}
    pub fn useStaticIpSta(self: *WiFi, cfg: IpConfig) !void {}

    // 低功耗与链路调优
    pub fn setPowerSave(self: *WiFi, ps: PowerSave) !void {}
    pub fn getPowerSave(self: *WiFi) !PowerSave {}
    pub fn setListenInterval(self: *WiFi, interval: u16) !void {}
    pub fn setMaxTxPower(self: *WiFi, quarter_dbm: i8) !void {}

    // 无线参数
    pub fn setProtocolMask(self: *WiFi, ifx: Mode, mask: u8) !void {}
    pub fn setBandwidth(self: *WiFi, ifx: Mode, bw: Bandwidth) !void {}
    pub fn setChannel(self: *WiFi, primary: u8, second: u8) !void {}
};
```

## Zig + C helper 分层

- `WiFi`（Zig）负责对外 API、状态管理、错误模型。
- `c_helper`（C）负责调用 ESP-IDF 原生接口（`esp_wifi` / `esp_netif` / `esp_event`）。
- `c_helper` 是内部实现细节，不作为对外 API 暴露。

目标：外部调用方只需要 `WiFi` 一个结构即可完成 Wi-Fi 操作。
