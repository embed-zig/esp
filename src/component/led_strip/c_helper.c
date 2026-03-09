#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "esp_err.h"
#include "led_strip.h"

#include "c_helper.h"
#include "led_strip_rmt.h"
#include "led_strip_spi.h"

int32_t espz_led_strip_new_rmt(
    int32_t gpio_num,
    uint32_t max_leds,
    uint32_t led_model,
    uint32_t color_format_id,
    bool invert_out,
    uint32_t resolution_hz,
    size_t mem_block_symbols,
    bool with_dma,
    void **out_handle)
{
    if (out_handle == NULL || max_leds == 0) {
        return ESP_ERR_INVALID_ARG;
    }

    const led_strip_config_t strip_cfg = {
        .strip_gpio_num = gpio_num,
        .max_leds = max_leds,
        .led_model = (led_model_t)led_model,
        .color_component_format.format_id = color_format_id,
        .flags.invert_out = invert_out,
    };

    const led_strip_rmt_config_t rmt_cfg = {
        .clk_src = RMT_CLK_SRC_DEFAULT,
        .resolution_hz = resolution_hz,
        .mem_block_symbols = mem_block_symbols,
        .flags.with_dma = with_dma,
    };

    led_strip_handle_t handle = NULL;
    const esp_err_t err = led_strip_new_rmt_device(&strip_cfg, &rmt_cfg, &handle);
    if (err != ESP_OK) {
        return err;
    }

    *out_handle = (void *)handle;
    return ESP_OK;
}

int32_t espz_led_strip_new_spi(
    int32_t gpio_num,
    uint32_t max_leds,
    uint32_t led_model,
    uint32_t color_format_id,
    bool invert_out,
    int32_t spi_bus,
    bool with_dma,
    void **out_handle)
{
    if (out_handle == NULL || max_leds == 0) {
        return ESP_ERR_INVALID_ARG;
    }

    const led_strip_config_t strip_cfg = {
        .strip_gpio_num = gpio_num,
        .max_leds = max_leds,
        .led_model = (led_model_t)led_model,
        .color_component_format.format_id = color_format_id,
        .flags.invert_out = invert_out,
    };

    const led_strip_spi_config_t spi_cfg = {
        .clk_src = SPI_CLK_SRC_DEFAULT,
        .spi_bus = (spi_host_device_t)spi_bus,
        .flags.with_dma = with_dma,
    };

    led_strip_handle_t handle = NULL;
    const esp_err_t err = led_strip_new_spi_device(&strip_cfg, &spi_cfg, &handle);
    if (err != ESP_OK) {
        return err;
    }

    *out_handle = (void *)handle;
    return ESP_OK;
}

int32_t espz_led_strip_set_pixel(
    void *handle,
    uint32_t index,
    uint32_t red,
    uint32_t green,
    uint32_t blue)
{
    if (handle == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return led_strip_set_pixel((led_strip_handle_t)handle, index, red, green, blue);
}

int32_t espz_led_strip_set_pixel_rgbw(
    void *handle,
    uint32_t index,
    uint32_t red,
    uint32_t green,
    uint32_t blue,
    uint32_t white)
{
    if (handle == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return led_strip_set_pixel_rgbw((led_strip_handle_t)handle, index, red, green, blue, white);
}

int32_t espz_led_strip_set_pixel_hsv(
    void *handle,
    uint32_t index,
    uint16_t hue,
    uint8_t saturation,
    uint8_t value)
{
    if (handle == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return led_strip_set_pixel_hsv((led_strip_handle_t)handle, index, hue, saturation, value);
}

int32_t espz_led_strip_refresh(void *handle)
{
    if (handle == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return led_strip_refresh((led_strip_handle_t)handle);
}

int32_t espz_led_strip_clear(void *handle)
{
    if (handle == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return led_strip_clear((led_strip_handle_t)handle);
}

int32_t espz_led_strip_del(void *handle)
{
    if (handle == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return led_strip_del((led_strip_handle_t)handle);
}
