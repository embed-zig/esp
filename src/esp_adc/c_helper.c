#include <stddef.h>
#include <stdint.h>

#include "esp_adc/adc_oneshot.h"
#include "esp_err.h"

int32_t espz_adc_oneshot_init(int unit_id, int channel, void **out_handle)
{
    if (out_handle == NULL) return ESP_ERR_INVALID_ARG;

    adc_oneshot_unit_handle_t unit = NULL;
    adc_oneshot_unit_init_cfg_t init_cfg = {
        .unit_id = unit_id,
        .ulp_mode = ADC_ULP_MODE_DISABLE,
    };
    esp_err_t err = adc_oneshot_new_unit(&init_cfg, &unit);
    if (err != ESP_OK) return err;

    adc_oneshot_chan_cfg_t chan_cfg = {
        .atten = ADC_ATTEN_DB_12,
        .bitwidth = ADC_BITWIDTH_DEFAULT,
    };
    err = adc_oneshot_config_channel(unit, channel, &chan_cfg);
    if (err != ESP_OK) {
        adc_oneshot_del_unit(unit);
        return err;
    }

    *out_handle = (void *)unit;
    return ESP_OK;
}

int32_t espz_adc_oneshot_read(void *handle, int channel, int *out_raw)
{
    if (handle == NULL || out_raw == NULL) return ESP_ERR_INVALID_ARG;
    return adc_oneshot_read((adc_oneshot_unit_handle_t)handle, channel, out_raw);
}
