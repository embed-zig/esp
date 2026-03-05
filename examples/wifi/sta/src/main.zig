const board = @import("board");
const esp_wifi = @import("esp_wifi");
const rom = @import("esp_rom");
const newlib = @import("newlib");
const freertos = @import("freertos");
const heap = @import("heap");

const WiFi = esp_wifi.WiFi;
const wifi_impl = esp_wifi.wifi;

const ScanConfig = wifi_impl.CScanConfig;
const ScanRecord = wifi_impl.CScanRecord;

fn wifiCheck(result: wifi_impl.Error!void) void {
    result catch {
        _ = rom.esp_rom_printf("FATAL WiFi error\n");
        newlib.abort();
    };
}

fn printSsid(ssid: [32]u8) void {
    var len: usize = 0;
    while (len < 32 and ssid[len] != 0) : (len += 1) {}
    var buf: [33]u8 = undefined;
    @memcpy(buf[0..len], ssid[0..len]);
    buf[len] = 0;
    _ = rom.esp_rom_printf("  %-24s", @as([*:0]const u8, @ptrCast(&buf)));
}

export fn zig_esp_main() callconv(.c) void {
    _ = rom.esp_rom_printf("wifi_sta: starting (scan + connect)\n");
    _ = rom.esp_rom_printf("heap: free=%u min_free=%u\n", heap.freeHeapSize(), heap.minimumFreeHeapSize());

    var wifi = WiFi.init() catch {
        _ = rom.esp_rom_printf("FATAL: WiFi init failed\n");
        newlib.abort();
    };

    wifiCheck(wifi.setMode(.sta));
    wifiCheck(wifi.start());

    _ = rom.esp_rom_printf("wifi_sta: scanning...\n");
    var records: [16]ScanRecord = undefined;
    var count: u16 = 0;
    const scan_rc = wifi_impl.espz_wifi_scan(
        &.{ .channel = 0, .show_hidden = true, .block_until_done = true, .max_results = 16 },
        &records,
        16,
        &count,
    );
    if (scan_rc == 0) {
        _ = rom.esp_rom_printf("wifi_sta: found %u networks:\n", @as(c_uint, count));
        var i: u16 = 0;
        while (i < count) : (i += 1) {
            printSsid(records[i].ssid);
            _ = rom.esp_rom_printf("rssi=%d ch=%u\n", @as(c_int, records[i].rssi), @as(c_uint, records[i].channel));
        }
    } else {
        _ = rom.esp_rom_printf("wifi_sta: scan failed: 0x%x\n", scan_rc);
    }

    _ = rom.esp_rom_printf("wifi_sta: connecting to %s ...\n", board.pins.wifi.ssid.ptr);
    wifi.configureSta(.{
        .ssid = board.pins.wifi.ssid,
        .password = board.pins.wifi.password,
        .listen_interval = board.pins.wifi.listen_interval,
    }) catch {
        _ = rom.esp_rom_printf("FATAL: configureSta failed\n");
        newlib.abort();
    };
    wifiCheck(wifi.connectSta());
    wifiCheck(wifi.setPowerSave(.min_modem));

    _ = rom.esp_rom_printf("wifi_sta: waiting for DHCP...\n");
    var got_ip = false;
    var wait: u32 = 0;
    while (wait < 100) : (wait += 1) {
        freertos.delay(100);
        const ip_result = wifi.getStaIp();
        if (ip_result) |ip| {
            if (ip.ip[0] != 0) {
                _ = rom.esp_rom_printf("wifi_sta: ip=%u.%u.%u.%u gw=%u.%u.%u.%u mask=%u.%u.%u.%u\n", @as(c_uint, ip.ip[0]), @as(c_uint, ip.ip[1]), @as(c_uint, ip.ip[2]), @as(c_uint, ip.ip[3]), @as(c_uint, ip.gateway[0]), @as(c_uint, ip.gateway[1]), @as(c_uint, ip.gateway[2]), @as(c_uint, ip.gateway[3]), @as(c_uint, ip.netmask[0]), @as(c_uint, ip.netmask[1]), @as(c_uint, ip.netmask[2]), @as(c_uint, ip.netmask[3]));
                got_ip = true;
                break;
            }
        } else |_| {}
    }

    if (!got_ip) {
        _ = rom.esp_rom_printf("wifi_sta: DHCP timeout\n");
    }

    const mac_result = wifi.getStaMac();
    if (mac_result) |mac| {
        _ = rom.esp_rom_printf("wifi_sta: mac=%02X:%02X:%02X:%02X:%02X:%02X\n", @as(c_uint, mac[0]), @as(c_uint, mac[1]), @as(c_uint, mac[2]), @as(c_uint, mac[3]), @as(c_uint, mac[4]), @as(c_uint, mac[5]));
    } else |_| {}

    _ = rom.esp_rom_printf("wifi_sta: holding 10s...\n");
    var hold: u32 = 0;
    while (hold < 100) : (hold += 1) {
        freertos.delay(100);
    }

    _ = rom.esp_rom_printf("wifi_sta: stopping\n");
    wifi.stop() catch {};
    wifi.deinit() catch {};
    _ = rom.esp_rom_printf("wifi_sta: done\n");
}
