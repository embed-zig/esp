#include <stddef.h>
#include <stdint.h>

#include "esp_err.h"
#include "esp_spiffs.h"

int32_t espz_spiffs_register(const char *label, const char *base_path,
                             int32_t max_files, int32_t format_if_failed)
{
    esp_vfs_spiffs_conf_t conf = {
        .base_path = base_path,
        .partition_label = label,
        .max_files = (size_t)max_files,
        .format_if_mount_failed = format_if_failed != 0,
    };
    return esp_vfs_spiffs_register(&conf);
}

int32_t espz_spiffs_unregister(const char *label)
{
    return esp_vfs_spiffs_unregister(label);
}

int32_t espz_spiffs_info(const char *label, size_t *total, size_t *used)
{
    return esp_spiffs_info(label, total, used);
}
