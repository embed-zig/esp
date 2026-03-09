# led_strip

Zig binding for the ESP-IDF `led_strip` component (espressif/led_strip).

## ESP-IDF component

Maps to [`espressif/led_strip`](https://components.espressif.com/components/espressif/led_strip) (v3.x), an external component from the ESP Component Registry.

Upstream source: [idf-extra-components/led_strip](https://github.com/espressif/idf-extra-components/tree/master/led_strip).

## Module boundary

Provides a typed Zig API for addressable LED strips (WS2812, SK6812, etc.) with two backend options:

- **RMT backend** — uses the RMT peripheral for precise timing; available on all ESP32 variants with `CONFIG_SOC_RMT_SUPPORTED`.
- **SPI backend** — uses the SPI peripheral for data transmission; available on chips with `CONFIG_SOC_GPSPI_SUPPORTED` and IDF >= 5.1.

Exposed operations:
- Create strip (RMT or SPI backend)
- Set pixel color (RGB, RGBW, HSV)
- Refresh (flush pixel buffer to hardware)
- Clear (turn off all LEDs)
- Delete (free resources)

Does **not** cover: custom LED encoders, RMT encoder internals, or direct pixel buffer access.

## Dependencies

- `led_strip` — the ESP-IDF external component (must be added via `idf_component.yml` or equivalent)
- `esp_driver_rmt` — RMT driver (for RMT backend)
- `esp_driver_spi` — SPI driver (for SPI backend)
