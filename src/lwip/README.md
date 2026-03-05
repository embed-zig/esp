# lwip

Sdkconfig bindings and BSD socket runtime API for the ESP-IDF lwIP stack.

## ESP-IDF component

Maps to [`lwip`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/lwip.html).

## Module boundary

- `config.zig` — sdkconfig bindings for lwIP tuning (buffer sizes, TCP/UDP options, etc.).
- `socket.zig` — Zig-friendly wrappers over the lwIP BSD socket API:
  - TCP: `socket`, `connect`, `send`, `recv`, `listen`, `accept`, `close`.
  - UDP: `sendTo`, `recvFrom`.
  - Options: `setRecvTimeout`, `setSendTimeout`, `setTcpNoDelay`, `setNonBlocking`.
  - Helpers: `bind`, `getBoundPort`, `htons`, `ntohs`.

IPv4 address utilities are shared with `esp_netif/netif.zig` to avoid duplication.

Does **not** cover raw sockets, IPv6, or netconn/pbuf-level APIs.

## Dependencies

- ESP-IDF `lwip` component (linked implicitly via the network stack).
- `esp_netif` module (for shared IP address conversion helpers).
