# usb

Sdkconfig binding for the ESP-IDF `usb` component.

## ESP-IDF component

Maps to [`usb`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/peripherals/usb_device.html).

## Module boundary

Provides sdkconfig options for the USB host stack: control transfer size, hub support, enumeration filter callbacks, and device-side TinyUSB configuration (CDC, MSC, MIDI, vendor, DFU). No runtime Zig API.

## Dependencies

No runtime dependencies.
