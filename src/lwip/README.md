# lwip

Sdkconfig binding for the ESP-IDF `lwip` component.

## ESP-IDF component

Maps to [`lwip`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/network/esp_netif.html) (underlying TCP/IP stack for `esp_netif`).

## Module boundary

Provides sdkconfig options for the lwIP TCP/IP stack: socket limits, TCP/UDP tuning, DHCP client/server, DNS, IPv4/IPv6, SNTP, PPP/SLIP, ICMP, hooks, and task configuration. No runtime Zig API.

## Dependencies

No runtime dependencies.
