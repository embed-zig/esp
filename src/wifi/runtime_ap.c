#include <string.h>
#include <stdint.h>

#include "esp_err.h"
#include "esp_event.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_wifi.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "nvs_flash.h"

#include "runtime_ap.h"

static const char *TAG = "wifi_ap";
static const char *DEFAULT_AP_SSID = "espz-ap";
static const uint8_t DEFAULT_AP_CHANNEL = 6;
static const uint8_t DEFAULT_AP_MAX_CONN = 4;

static esp_err_t init_nvs_storage(void)
{
    esp_err_t err = nvs_flash_init();
    if (err == ESP_ERR_NVS_NO_FREE_PAGES || err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        err = nvs_flash_init();
    }
    return err;
}

void espz_wifi_ap_example_main(void)
{
#if !defined(CONFIG_ESP_WIFI_ENABLED) || !CONFIG_ESP_WIFI_ENABLED
    ESP_LOGW(TAG, "CONFIG_ESP_WIFI_ENABLED is disabled, skip ap example");
    return;
#else
    ESP_LOGI(TAG, "wifi_ap_start");

    ESP_ERROR_CHECK(init_nvs_storage());
    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());

    esp_netif_t *ap_netif = esp_netif_create_default_wifi_ap();
    if (ap_netif == NULL) {
        ESP_LOGE(TAG, "failed to create default wifi ap netif");
        return;
    }

    wifi_init_config_t init_cfg = WIFI_INIT_CONFIG_DEFAULT();
    ESP_ERROR_CHECK(esp_wifi_init(&init_cfg));
    ESP_ERROR_CHECK(esp_wifi_set_mode(WIFI_MODE_AP));

    wifi_config_t ap_cfg = {0};
    const size_t ssid_len = strlen(DEFAULT_AP_SSID);
    memcpy(ap_cfg.ap.ssid, DEFAULT_AP_SSID, ssid_len);
    ap_cfg.ap.ssid_len = (uint8_t)ssid_len;
    ap_cfg.ap.channel = DEFAULT_AP_CHANNEL;
    ap_cfg.ap.max_connection = DEFAULT_AP_MAX_CONN;
    ap_cfg.ap.authmode = WIFI_AUTH_OPEN;

    ESP_ERROR_CHECK(esp_wifi_set_config(WIFI_IF_AP, &ap_cfg));
    ESP_ERROR_CHECK(esp_wifi_start());

    ESP_LOGI(
        TAG,
        "wifi_ap_ready ssid=%s channel=%u max_conn=%u",
        DEFAULT_AP_SSID,
        (unsigned)DEFAULT_AP_CHANNEL,
        (unsigned)DEFAULT_AP_MAX_CONN);

    vTaskDelay(pdMS_TO_TICKS(10000));

    ESP_ERROR_CHECK(esp_wifi_stop());
    ESP_ERROR_CHECK(esp_wifi_deinit());
    ESP_ERROR_CHECK(esp_wifi_clear_default_wifi_driver_and_handlers(ap_netif));
    esp_netif_destroy(ap_netif);
    ESP_ERROR_CHECK(esp_event_loop_delete_default());
    ESP_LOGI(TAG, "wifi_ap_stop");
#endif
}
