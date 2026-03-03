#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "driver/spi_master.h"
#include "esp_err.h"
#include "esp_lcd_io_spi.h"
#include "esp_lcd_panel_io.h"
#include "esp_lcd_panel_ops.h"
#include "esp_lcd_panel_vendor.h"
#include "esp_lcd_types.h"

#if __has_include("esp_lcd_ili9341.h")
#include "esp_lcd_ili9341.h"
#define ESPZ_LCD_ILI9341_SUPPORTED 1
#endif

#include "c_helper.h"

static esp_err_t parse_rgb_element_order(uint32_t value, lcd_rgb_element_order_t *out)
{
    if (out == NULL) {
        return ESP_ERR_INVALID_ARG;
    }

    switch (value) {
    case 0:
        *out = LCD_RGB_ELEMENT_ORDER_RGB;
        return ESP_OK;
    case 1:
        *out = LCD_RGB_ELEMENT_ORDER_BGR;
        return ESP_OK;
    default:
        return ESP_ERR_INVALID_ARG;
    }
}

int32_t espz_lcd_spi_bus_init(
    int32_t host_id,
    int32_t sclk_io_num,
    int32_t mosi_io_num,
    int32_t miso_io_num,
    size_t max_transfer_bytes,
    int32_t dma_channel)
{
    if (max_transfer_bytes == 0) {
        return ESP_ERR_INVALID_ARG;
    }

    const spi_bus_config_t cfg = {
        .sclk_io_num = sclk_io_num,
        .mosi_io_num = mosi_io_num,
        .miso_io_num = miso_io_num,
        .quadwp_io_num = -1,
        .quadhd_io_num = -1,
        .max_transfer_sz = (int)max_transfer_bytes,
    };

    return spi_bus_initialize((spi_host_device_t)host_id, &cfg, dma_channel);
}

int32_t espz_lcd_spi_bus_deinit(int32_t host_id)
{
    return spi_bus_free((spi_host_device_t)host_id);
}

int32_t espz_lcd_new_panel_io_spi(
    int32_t host_id,
    int32_t cs_io_num,
    int32_t dc_io_num,
    uint32_t pclk_hz,
    uint8_t spi_mode,
    uint8_t cmd_bits,
    uint8_t param_bits,
    uint32_t trans_queue_depth,
    void **out_handle)
{
    if (out_handle == NULL || pclk_hz == 0) {
        return ESP_ERR_INVALID_ARG;
    }

    esp_lcd_panel_io_handle_t handle = NULL;
    const esp_lcd_panel_io_spi_config_t io_cfg = {
        .dc_gpio_num = dc_io_num,
        .cs_gpio_num = cs_io_num,
        .pclk_hz = pclk_hz,
        .lcd_cmd_bits = cmd_bits,
        .lcd_param_bits = param_bits,
        .spi_mode = spi_mode,
        .trans_queue_depth = (int)trans_queue_depth,
    };

    const esp_err_t err = esp_lcd_new_panel_io_spi(
        (esp_lcd_spi_bus_handle_t)host_id,
        &io_cfg,
        &handle);
    if (err != ESP_OK) {
        return err;
    }

    *out_handle = (void *)handle;
    return ESP_OK;
}

int32_t espz_lcd_panel_io_del(void *io_handle)
{
    if (io_handle == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_io_del((esp_lcd_panel_io_handle_t)io_handle);
}

int32_t espz_lcd_panel_io_tx_param(void *io_handle, uint32_t cmd, const void *params, size_t params_size)
{
    if (io_handle == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_io_tx_param((esp_lcd_panel_io_handle_t)io_handle, (int)cmd, params, params_size);
}

int32_t espz_lcd_panel_io_tx_color(void *io_handle, uint32_t cmd, const void *colors, size_t color_size)
{
    if (io_handle == NULL || colors == NULL || color_size == 0) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_io_tx_color((esp_lcd_panel_io_handle_t)io_handle, (int)cmd, colors, color_size);
}

int32_t espz_lcd_panel_io_rx_param(void *io_handle, uint32_t cmd, void *out_params, size_t out_size)
{
    if (io_handle == NULL || out_params == NULL || out_size == 0) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_io_rx_param((esp_lcd_panel_io_handle_t)io_handle, (int)cmd, out_params, out_size);
}

static int32_t new_panel_vendor_common(
    void *io_handle,
    int32_t reset_gpio_num,
    uint32_t rgb_element_order,
    uint8_t bits_per_pixel,
    void **out_panel_handle,
    esp_err_t (*new_panel_fn)(
        const esp_lcd_panel_io_handle_t,
        const esp_lcd_panel_dev_config_t *,
        esp_lcd_panel_handle_t *))
{
    if (io_handle == NULL || out_panel_handle == NULL || bits_per_pixel == 0) {
        return ESP_ERR_INVALID_ARG;
    }

    lcd_rgb_element_order_t order = LCD_RGB_ELEMENT_ORDER_RGB;
    const esp_err_t order_err = parse_rgb_element_order(rgb_element_order, &order);
    if (order_err != ESP_OK) {
        return order_err;
    }

    esp_lcd_panel_handle_t panel = NULL;
    const esp_lcd_panel_dev_config_t cfg = {
        .reset_gpio_num = reset_gpio_num,
        .rgb_ele_order = order,
        .bits_per_pixel = bits_per_pixel,
    };

    const esp_err_t err = new_panel_fn((esp_lcd_panel_io_handle_t)io_handle, &cfg, &panel);
    if (err != ESP_OK) {
        return err;
    }

    *out_panel_handle = (void *)panel;
    return ESP_OK;
}

int32_t espz_lcd_new_panel_st7789(
    void *io_handle,
    int32_t reset_gpio_num,
    uint32_t rgb_element_order,
    uint8_t bits_per_pixel,
    void **out_panel_handle)
{
    return new_panel_vendor_common(
        io_handle,
        reset_gpio_num,
        rgb_element_order,
        bits_per_pixel,
        out_panel_handle,
        esp_lcd_new_panel_st7789);
}

int32_t espz_lcd_new_panel_ili9341(
    void *io_handle,
    int32_t reset_gpio_num,
    uint32_t rgb_element_order,
    uint8_t bits_per_pixel,
    void **out_panel_handle)
{
#ifdef ESPZ_LCD_ILI9341_SUPPORTED
    return new_panel_vendor_common(
        io_handle,
        reset_gpio_num,
        rgb_element_order,
        bits_per_pixel,
        out_panel_handle,
        esp_lcd_new_panel_ili9341);
#else
    (void)io_handle;
    (void)reset_gpio_num;
    (void)rgb_element_order;
    (void)bits_per_pixel;
    (void)out_panel_handle;
    return ESP_ERR_NOT_SUPPORTED;
#endif
}

int32_t espz_lcd_panel_reset(void *panel)
{
    if (panel == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_reset((esp_lcd_panel_handle_t)panel);
}

int32_t espz_lcd_panel_init(void *panel)
{
    if (panel == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_init((esp_lcd_panel_handle_t)panel);
}

int32_t espz_lcd_panel_del(void *panel)
{
    if (panel == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_del((esp_lcd_panel_handle_t)panel);
}

int32_t espz_lcd_panel_draw_bitmap(
    void *panel,
    int32_t x_start,
    int32_t y_start,
    int32_t x_end,
    int32_t y_end,
    const void *color_data)
{
    if (panel == NULL || x_end <= x_start || y_end <= y_start) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_draw_bitmap((esp_lcd_panel_handle_t)panel, x_start, y_start, x_end, y_end, color_data);
}

int32_t espz_lcd_panel_mirror(void *panel, bool mirror_x, bool mirror_y)
{
    if (panel == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_mirror((esp_lcd_panel_handle_t)panel, mirror_x, mirror_y);
}

int32_t espz_lcd_panel_swap_xy(void *panel, bool enabled)
{
    if (panel == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_swap_xy((esp_lcd_panel_handle_t)panel, enabled);
}

int32_t espz_lcd_panel_invert_color(void *panel, bool enabled)
{
    if (panel == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_invert_color((esp_lcd_panel_handle_t)panel, enabled);
}

int32_t espz_lcd_panel_set_gap(void *panel, int32_t x_gap, int32_t y_gap)
{
    if (panel == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_set_gap((esp_lcd_panel_handle_t)panel, x_gap, y_gap);
}

int32_t espz_lcd_panel_disp_on_off(void *panel, bool enabled)
{
    if (panel == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_disp_on_off((esp_lcd_panel_handle_t)panel, enabled);
}

int32_t espz_lcd_panel_disp_sleep(void *panel, bool enabled)
{
    if (panel == NULL) {
        return ESP_ERR_INVALID_ARG;
    }
    return esp_lcd_panel_disp_sleep((esp_lcd_panel_handle_t)panel, enabled);
}
