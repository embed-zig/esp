#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "esp_err.h"
#include "nvs.h"

enum
{
    ESPZ_OK = 0,
    ESPZ_ERR_INVALID_ARG = 1,
    ESPZ_ERR_NOT_FOUND = 2,
    ESPZ_ERR_BUFFER_TOO_SMALL = 3,
    ESPZ_ERR_STORAGE_FULL = 4,
    ESPZ_ERR_SCHEMA_MISMATCH = 5,
    ESPZ_ERR_FAIL = 100,
};

static int32_t espz_map_err(esp_err_t err)
{
    switch (err) {
    case ESP_OK:
        return ESPZ_OK;
    case ESP_ERR_INVALID_ARG:
        return ESPZ_ERR_INVALID_ARG;
    case ESP_ERR_NVS_NOT_FOUND:
        return ESPZ_ERR_NOT_FOUND;
    case ESP_ERR_NVS_INVALID_LENGTH:
        return ESPZ_ERR_BUFFER_TOO_SMALL;
    case ESP_ERR_NVS_NOT_ENOUGH_SPACE:
    case ESP_ERR_NVS_NO_FREE_PAGES:
        return ESPZ_ERR_STORAGE_FULL;
    case ESP_ERR_NVS_NEW_VERSION_FOUND:
        return ESPZ_ERR_SCHEMA_MISMATCH;
    default:
        return ESPZ_ERR_FAIL;
    }
}

static int32_t espz_make_name(const uint8_t *src, size_t len, char *dst, size_t dst_cap)
{
    if (src == NULL || dst == NULL || len == 0) return ESPZ_ERR_INVALID_ARG;
    if (len + 1 > dst_cap) return ESPZ_ERR_INVALID_ARG;
    memcpy(dst, src, len);
    dst[len] = '\0';
    return ESPZ_OK;
}

int32_t espz_nvs_open_rw(const uint8_t *ns_ptr, size_t ns_len, uint32_t *out_handle)
{
    if (out_handle == NULL) return ESPZ_ERR_INVALID_ARG;

    char ns[16] = {0};
    int32_t mk = espz_make_name(ns_ptr, ns_len, ns, sizeof(ns));
    if (mk != ESPZ_OK) return mk;

    nvs_handle_t h = 0;
    esp_err_t err = nvs_open(ns, NVS_READWRITE, &h);
    if (err != ESP_OK) return espz_map_err(err);
    *out_handle = (uint32_t)h;
    return ESPZ_OK;
}

void espz_nvs_close(uint32_t handle)
{
    nvs_close((nvs_handle_t)handle);
}

int32_t espz_nvs_get_u32(uint32_t handle, const uint8_t *key_ptr, size_t key_len, uint32_t *out)
{
    if (out == NULL) return ESPZ_ERR_INVALID_ARG;
    char key[16] = {0};
    int32_t mk = espz_make_name(key_ptr, key_len, key, sizeof(key));
    if (mk != ESPZ_OK) return mk;
    return espz_map_err(nvs_get_u32((nvs_handle_t)handle, key, out));
}

int32_t espz_nvs_set_u32(uint32_t handle, const uint8_t *key_ptr, size_t key_len, uint32_t value)
{
    char key[16] = {0};
    int32_t mk = espz_make_name(key_ptr, key_len, key, sizeof(key));
    if (mk != ESPZ_OK) return mk;
    return espz_map_err(nvs_set_u32((nvs_handle_t)handle, key, value));
}

int32_t espz_nvs_get_i32(uint32_t handle, const uint8_t *key_ptr, size_t key_len, int32_t *out)
{
    if (out == NULL) return ESPZ_ERR_INVALID_ARG;
    char key[16] = {0};
    int32_t mk = espz_make_name(key_ptr, key_len, key, sizeof(key));
    if (mk != ESPZ_OK) return mk;
    return espz_map_err(nvs_get_i32((nvs_handle_t)handle, key, out));
}

int32_t espz_nvs_set_i32(uint32_t handle, const uint8_t *key_ptr, size_t key_len, int32_t value)
{
    char key[16] = {0};
    int32_t mk = espz_make_name(key_ptr, key_len, key, sizeof(key));
    if (mk != ESPZ_OK) return mk;
    return espz_map_err(nvs_set_i32((nvs_handle_t)handle, key, value));
}

int32_t espz_nvs_get_blob(
    uint32_t handle,
    const uint8_t *key_ptr,
    size_t key_len,
    uint8_t *out_buf,
    size_t out_cap,
    size_t *out_len)
{
    if (out_buf == NULL || out_len == NULL) return ESPZ_ERR_INVALID_ARG;
    char key[16] = {0};
    int32_t mk = espz_make_name(key_ptr, key_len, key, sizeof(key));
    if (mk != ESPZ_OK) return mk;

    size_t len = out_cap;
    esp_err_t err = nvs_get_blob((nvs_handle_t)handle, key, out_buf, &len);
    if (err != ESP_OK) return espz_map_err(err);
    *out_len = len;
    return ESPZ_OK;
}

int32_t espz_nvs_set_blob(
    uint32_t handle,
    const uint8_t *key_ptr,
    size_t key_len,
    const uint8_t *data_ptr,
    size_t data_len)
{
    if (data_ptr == NULL && data_len != 0) return ESPZ_ERR_INVALID_ARG;
    char key[16] = {0};
    int32_t mk = espz_make_name(key_ptr, key_len, key, sizeof(key));
    if (mk != ESPZ_OK) return mk;
    return espz_map_err(nvs_set_blob((nvs_handle_t)handle, key, data_ptr, data_len));
}

int32_t espz_nvs_erase_key(uint32_t handle, const uint8_t *key_ptr, size_t key_len)
{
    char key[16] = {0};
    int32_t mk = espz_make_name(key_ptr, key_len, key, sizeof(key));
    if (mk != ESPZ_OK) return mk;
    return espz_map_err(nvs_erase_key((nvs_handle_t)handle, key));
}

int32_t espz_nvs_erase_all(uint32_t handle)
{
    return espz_map_err(nvs_erase_all((nvs_handle_t)handle));
}

int32_t espz_nvs_commit(uint32_t handle)
{
    return espz_map_err(nvs_commit((nvs_handle_t)handle));
}
