#include <stddef.h>
#include <stdint.h>

#include "esp_err.h"
#include "esp_ota_ops.h"
#include "esp_system.h"

const void *espz_ota_get_next_update_partition(const void *from)
{
    return esp_ota_get_next_update_partition((const esp_partition_t *)from);
}

const void *espz_ota_get_running_partition(void)
{
    return esp_ota_get_running_partition();
}

int32_t espz_ota_begin(const void *partition, size_t image_size, uint32_t *out_handle)
{
    if (out_handle == NULL) return ESP_ERR_INVALID_ARG;
    esp_ota_handle_t h = 0;
    esp_err_t err = esp_ota_begin((const esp_partition_t *)partition, image_size, &h);
    if (err != ESP_OK) return err;
    *out_handle = (uint32_t)h;
    return ESP_OK;
}

int32_t espz_ota_write(uint32_t handle, const uint8_t *data, size_t size)
{
    return esp_ota_write((esp_ota_handle_t)handle, data, size);
}

int32_t espz_ota_end(uint32_t handle)
{
    return esp_ota_end((esp_ota_handle_t)handle);
}

int32_t espz_ota_abort(uint32_t handle)
{
    return esp_ota_abort((esp_ota_handle_t)handle);
}

int32_t espz_ota_set_boot_partition(const void *partition)
{
    return esp_ota_set_boot_partition((const esp_partition_t *)partition);
}

int32_t espz_ota_get_state_partition(const void *partition, uint32_t *out_state)
{
    if (out_state == NULL) return ESP_ERR_INVALID_ARG;
    esp_ota_img_states_t state = ESP_OTA_IMG_UNDEFINED;
    esp_err_t err = esp_ota_get_state_partition((const esp_partition_t *)partition, &state);
    if (err != ESP_OK) return err;
    *out_state = (uint32_t)state;
    return ESP_OK;
}

int32_t espz_ota_mark_valid(void)
{
    return esp_ota_mark_app_valid_cancel_rollback();
}

int32_t espz_ota_mark_invalid_rollback(void)
{
    return esp_ota_mark_app_invalid_rollback_and_reboot();
}

void espz_system_restart(void)
{
    esp_restart();
}
