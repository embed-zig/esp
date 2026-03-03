# soc

Sdkconfig binding for the ESP-IDF `soc` component.

## ESP-IDF component

Maps to `soc` (internal hardware abstraction layer — declares SoC peripheral capabilities).

## Module boundary

Provides sdkconfig options that describe SoC hardware capabilities: supported peripherals (ADC, SPI, I2C, UART, USB, etc.), DMA channels, GPIO counts, timer groups, and feature flags. These are read-only descriptors set by the target chip. No runtime Zig API.

## Dependencies

No runtime dependencies.
