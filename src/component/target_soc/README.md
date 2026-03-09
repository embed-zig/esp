# target_soc

Sdkconfig binding for target-specific SoC configuration.

## ESP-IDF component

Maps to internal target SoC configuration (chip-specific settings for ESP32-S3 and related targets).

## Module boundary

Provides sdkconfig options for target-specific SoC features: brownout detection, flash/PSRAM frequency and mode, SPIRAM configuration, and chip-variant feature flags. These settings are specific to the selected chip target. No runtime Zig API.

## Dependencies

No runtime dependencies.
