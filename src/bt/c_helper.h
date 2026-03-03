#pragma once

#include <stdint.h>

int32_t espz_bt_controller_init_default(void);
int32_t espz_bt_controller_enable(uint32_t mode);
int32_t espz_bt_controller_disable(void);
int32_t espz_bt_controller_deinit(void);
