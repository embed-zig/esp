#include <stdlib.h>
#include <string.h>

#include "esp_event.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_wifi.h"
#include "nvs_flash.h"

#include "runtime_scan.h"

static const char *TAG = "wifi_scan";
static const uint16_t MAX_LOGGED_AP = 12;

static esp_err_t init_nvs_storage(void)
{
    esp_err_t err = nvs_flash_init();
    if (err == ESP_ERR_NVS_NO_FREE_PAGES || err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        err = nvs_flash_init();
    }
    return err;
}

void espz_wifi_scan_example_main(void)
{
#if !defined(CONFIG_ESP_WIFI_ENABLED) || !CONFIG_ESP_WIFI_ENABLED
    ESP_LOGW(TAG, "CONFIG_ESP_WIFI_ENABLED is disabled, skip wifi scan");
    return;
#else
    ESP_LOGI(TAG, "wifi_scan_start");

    ESP_ERROR_CHECK(init_nvs_storage());
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());

    esp_netif_t *sta_netif = esp_netif_create_default_wifi_sta();
    if (sta_netif == NULL) {
        ESP_LOGE(TAG, "failed to create default wifi sta netif");
        return;
    }

    wifi_init_config_t init_cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&init_cfg));
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_STA));
    ESP_ERROR_CHECK(esp_wifi_start());

    wifi_scan_config_t scan_cfg = {0};
    ESP_ERROR_CHECK(esp_wifi_scan_start(&scan_cfg, true));

    uint16_t ap_count = 0;
    ESP_ERROR_CHECK(esp_wifi_scan_get_ap_num(&ap_count));

    const uint16_t shown_count = ap_count > MAX_LOGGED_AP ? MAX_LOGGED_AP : ap_count;
    ESP_LOGI(TAG, "wifi_scan_result total=%u shown=%u", (unsigned)ap_count, (unsigned)shown_count);

    if (shown_count > 0) {
        wifi_ap_record_t *records = calloc(shown_count, sizeof(wifi_ap_record_t));
        if (records == NULL) {
            ESP_LOGW(TAG, "unable to allocate ap record buffer");
        } else {
            uint16_t fetched = shown_count;
            ESP_ERROR_CHECK(esp_wifi_scan_get_ap_records(&fetched, records));
            for (uint16_t i = 0; i < fetched; i++) {
                const wifi_ap_record_t *ap = &records[i];
                ESP_LOGI(
                    TAG,
                    "ap[%u] ssid=%s rssi=%d auth=%d channel=%u",
                    (unsigned)i,
                    (const char *)ap->ssid,
                    (int)ap->rssi,
                    (int)ap->authmode,
                    (unsigned)ap->primary);
            }
            free(records);
        }
    }

    ESP_ERROR_CHECK(esp_wifi_stop());
    ESP_ERROR_CHECK(esp_wifi_deinit());
    ESP_ERROR_CHECK(esp_wifi_clear_default_wifi_driver_and_handlers(sta_netif));
    esp_netif_destroy(sta_netif);
    ESP_ERROR_CHECK(esp_event_loop_delete_default());
#endif
}
