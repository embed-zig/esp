# spi_flash

Sdkconfig binding for the ESP-IDF `spi_flash` component.

## ESP-IDF component

Maps to [`spi_flash`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/storage/spi_flash.html).

## Module boundary

Provides sdkconfig options for SPI flash access: dangerous writes, auto-suspend, encryption, yield during erase, flash size override, HPM support, and brownout detection behavior. No runtime Zig API.

## Dependencies

No runtime dependencies.
