# mqtt

Sdkconfig binding for the ESP-IDF `mqtt` component.

## ESP-IDF component

Maps to [`mqtt`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/protocols/mqtt.html).

## Module boundary

Provides sdkconfig options for the ESP-MQTT client: protocol version (3.1.1/5), transport modes (TCP, SSL, WebSocket), task core affinity, custom outbox, and message handling. No runtime Zig API.

## Dependencies

No runtime dependencies.
