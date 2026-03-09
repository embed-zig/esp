const esp = @import("esp");
const esp_component = esp.component;
const board = @import("board");
const esp_wifi = esp_component.esp_wifi;
const rom = esp_component.esp_rom;
const newlib = esp_component.newlib;
const freertos = esp_component.freertos;
const heap = esp_component.heap;

const WiFi = esp_wifi.WiFi;

fn wifiCheck(result: esp_wifi.wifi.Error!void) void {
    result catch {
        _ = rom.esp_rom_printf("FATAL WiFi error\n");
        newlib.abort();
    };
}

export fn zig_esp_main() callconv(.c) void {
    _ = rom.esp_rom_printf("wifi_ap: starting (pure zig)\n");
    _ = rom.esp_rom_printf("heap: free=%u min_free=%u\n", heap.freeHeapSize(), heap.minimumFreeHeapSize());

    var wifi = WiFi.init() catch {
        _ = rom.esp_rom_printf("FATAL: WiFi init failed\n");
        newlib.abort();
    };

    const ap = board.pins.wifi_ap;
    wifi.startAp(.{
        .ssid = ap.ssid,
        .password = ap.password,
        .channel = ap.channel,
        .max_connection = ap.max_connection,
        .hidden = ap.hidden,
    }) catch {
        _ = rom.esp_rom_printf("FATAL: WiFi startAp failed\n");
        newlib.abort();
    };

    wifiCheck(wifi.setPowerSave(.none));

    _ = rom.esp_rom_printf("wifi_ap: AP started, ssid=%s channel=%u\n", ap.ssid.ptr, @as(c_uint, ap.channel));

    while (true) {
        freertos.delay(100);
    }
}
