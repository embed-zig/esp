#include <stdint.h>

#include "esp_timer.h"

int64_t espz_timer_get_time(void)
{
    return esp_timer_get_time();
}
