const esp = @import("esp");
const esp_component = esp.component;
const esp_wifi = esp_component.esp_wifi;
const rom = esp_component.esp_rom;
const newlib = esp_component.newlib;
const freertos = esp_component.freertos;

const WiFi = esp_wifi.WiFi;

fn wifiCheck(result: esp_wifi.wifi.Error!void) void {
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
    _ = rom.esp_rom_printf("wifi_scan: starting\n");

    var wifi = WiFi.init() catch {
        _ = rom.esp_rom_printf("FATAL: WiFi init failed\n");
        newlib.abort();
    };

    wifiCheck(wifi.setMode(.sta));
    wifiCheck(wifi.start());

    _ = rom.esp_rom_printf("wifi_scan: scanning...\n");

    const scan_cfg = WiFi.ScanConfig{
        .channel = 0,
        .show_hidden = false,
        .block_until_done = true,
        .max_results = 12,
    };
    var c_cfg = esp_wifi.wifi.CScanConfig{
        .channel = scan_cfg.channel,
        .show_hidden = scan_cfg.show_hidden,
        .block_until_done = scan_cfg.block_until_done,
        .max_results = scan_cfg.max_results,
    };
    var records: [12]esp_wifi.wifi.CScanRecord = undefined;
    var count: u16 = 0;

    const rc = esp_wifi.wifi.espz_wifi_scan(&c_cfg, &records, 12, &count);
    if (rc == esp_wifi.wifi.esp_ok) {
        _ = rom.esp_rom_printf("wifi_scan: found %u networks:\n", @as(c_uint, count));
        var i: u16 = 0;
        while (i < count) : (i += 1) {
            printSsid(records[i].ssid);
            _ = rom.esp_rom_printf("rssi=%d ch=%u\n", @as(c_int, records[i].rssi), @as(c_uint, records[i].channel));
        }
    } else {
        _ = rom.esp_rom_printf("wifi_scan: scan failed: 0x%x\n", rc);
    }

    _ = rom.esp_rom_printf("wifi_scan: done\n");
    wifi.stop() catch {};
    wifi.deinit() catch {};
}
