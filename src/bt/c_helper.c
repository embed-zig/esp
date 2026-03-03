#include <stdint.h>
#include "esp_bt.h"
#include "c_helper.h"

int32_t espz_bt_controller_init_default(void)
{
    esp_bt_controller_config_t cfg = BT_CONTROLLER_INIT_CONFIG_DEFAULT();
    return esp_bt_controller_init(&cfg);
}

int32_t espz_bt_controller_enable(uint32_t mode)
{
    return esp_bt_controller_enable((esp_bt_mode_t)mode);
}

int32_t espz_bt_controller_disable(void)
{
    return esp_bt_controller_disable();
}

int32_t espz_bt_controller_deinit(void)
{
    return esp_bt_controller_deinit();
}
