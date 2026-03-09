# esp_misc

Sdkconfig binding for miscellaneous ESP-IDF system options that do not map to a single component.

## ESP-IDF component

Aggregates sdkconfig keys from multiple ESP-IDF subsystems (brownout detector, console, CPU frequency, watchdogs, MAC addressing, ROM capabilities, TLS, protocomm, and more). No single upstream component page.

## Module boundary

Typed sdkconfig definitions for cross-cutting system configuration. Covers brownout detection, UART/USB console routing, CPU frequency, interrupt/task watchdogs, IPC, MAC address policy, main task sizing, ROM feature flags, TLS settings, and protocomm security versions. No runtime Zig API.

## Dependencies

No runtime dependencies.
