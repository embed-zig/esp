const esp_netif = @import("esp_netif");

comptime {
    _ = esp_netif.netif;
    _ = esp_netif.netif.Handle;
    _ = esp_netif.netif.IpInfo;
    _ = esp_netif.netif.getIpInfo;
    _ = esp_netif.netif.setDefaultNetif;
    _ = esp_netif.netif.ip4ToBytes;
    _ = esp_netif.netif.ip4FromBytes;
}

export fn zig_esp_main() callconv(.c) void {}
