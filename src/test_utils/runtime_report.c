#include <inttypes.h>
#include <stddef.h>
#include <stdbool.h>

#include "esp_heap_caps.h"
#include "esp_log.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "sdkconfig.h"

#include "runtime_report.h"

static const char *TAG = "hello_world";

#ifndef ESPZ_BOARD_PROFILE
#define ESPZ_BOARD_PROFILE "unknown"
#endif

static const char *enabled_text(bool enabled)
{
    return enabled ? "enabled" : "disabled";
}

static void log_config_summary(void)
{
    ESP_LOGI(TAG, "config_board_profile=%s", ESPZ_BOARD_PROFILE);
    ESP_LOGI(TAG, "config_idf_target=%s", CONFIG_IDF_TARGET);
    ESP_LOGI(TAG, "config_freertos_hz=%d", CONFIG_FREERTOS_HZ);
    ESP_LOGI(TAG, "config_main_task_stack=%d", CONFIG_ESP_MAIN_TASK_STACK_SIZE);

#if defined(CONFIG_PARTITION_TABLE_CUSTOM) && CONFIG_PARTITION_TABLE_CUSTOM
    ESP_LOGI(TAG,
             "config_partition_table=custom file=%s offset=0x%X",
             CONFIG_PARTITION_TABLE_CUSTOM_FILENAME,
             CONFIG_PARTITION_TABLE_OFFSET);
#else
    ESP_LOGI(TAG, "config_partition_table=default");
#endif

#if defined(CONFIG_SPIRAM) && CONFIG_SPIRAM
    ESP_LOGI(TAG, "config_psram=%s", enabled_text(true));
#else
    ESP_LOGI(TAG, "config_psram=%s", enabled_text(false));
#endif
}

static void log_memory_usage(void)
{
    const size_t iram_total = heap_caps_get_total_size(MALLOC_CAP_INTERNAL);
    const size_t iram_free = heap_caps_get_free_size(MALLOC_CAP_INTERNAL);
    const size_t iram_used = iram_total - iram_free;

    const size_t psram_total = heap_caps_get_total_size(MALLOC_CAP_SPIRAM);
    const size_t psram_free = heap_caps_get_free_size(MALLOC_CAP_SPIRAM);
    const size_t psram_used = psram_total - psram_free;

    ESP_LOGI(TAG, "iram_usage_bytes used=%" PRIu32 " free=%" PRIu32 " total=%" PRIu32,
             (uint32_t)iram_used,
             (uint32_t)iram_free,
             (uint32_t)iram_total);

    ESP_LOGI(TAG, "psram_usage_bytes used=%" PRIu32 " free=%" PRIu32 " total=%" PRIu32,
             (uint32_t)psram_used,
             (uint32_t)psram_free,
             (uint32_t)psram_total);
}

void zig_esp_main(void)
{
    ESP_LOGI(TAG, "hello world up");
    log_config_summary();

    uint32_t stable_seconds = 0;
    while (1) {
        ESP_LOGI(TAG, "stable_runtime_seconds=%" PRIu32, stable_seconds);
        log_memory_usage();

        stable_seconds += 2;
        vTaskDelay(pdMS_TO_TICKS(2000));
    }
}
