# tcp_transport

Sdkconfig binding for the ESP-IDF `tcp_transport` component.

## ESP-IDF component

Maps to [`tcp_transport`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/protocols/esp_tls.html) (transport layer used by MQTT, HTTP client, etc.).

## Module boundary

Provides sdkconfig options for the TCP transport layer: TCP retransmission limits, WS dynamic buffer, proxy support, and ESP-TLS settings (certificate bundle, client/server verification, PSK, skip server verification). No runtime Zig API.

## Dependencies

No runtime dependencies.
