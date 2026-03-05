#include <stdint.h>

#include "driver/gpio.h"
#include "esp_err.h"

int32_t espz_gpio_set_direction(int pin, int mode)
{
    return gpio_set_direction((gpio_num_t)pin, (gpio_mode_t)mode);
}

int32_t espz_gpio_set_level(int pin, uint32_t level)
{
    return gpio_set_level((gpio_num_t)pin, level);
}

int espz_gpio_get_level(int pin)
{
    return gpio_get_level((gpio_num_t)pin);
}

int32_t espz_gpio_set_pull_mode(int pin, int pull)
{
    return gpio_set_pull_mode((gpio_num_t)pin, (gpio_pull_mode_t)pull);
}

int32_t espz_gpio_reset_pin(int pin)
{
    return gpio_reset_pin((gpio_num_t)pin);
}
