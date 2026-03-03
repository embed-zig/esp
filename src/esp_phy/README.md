# esp_phy

Sdkconfig binding for the ESP-IDF `esp_phy` component.

## ESP-IDF component

Maps to [`esp_phy`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/network/esp_wifi.html) (PHY configuration is part of the Wi-Fi/BT radio subsystem).

## Module boundary

Provides sdkconfig bindings for RF PHY calibration, TX power limits, USB PHY, and init-data storage options. Controls radio hardware initialization behavior shared by Wi-Fi and Bluetooth.

## Dependencies

No runtime dependencies.
