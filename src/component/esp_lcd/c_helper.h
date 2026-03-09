#pragma once

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

int32_t espz_lcd_spi_bus_init(
    int32_t host_id,
    int32_t sclk_io_num,
    int32_t mosi_io_num,
    int32_t miso_io_num,
    size_t max_transfer_bytes,
    int32_t dma_channel);

int32_t espz_lcd_spi_bus_deinit(int32_t host_id);

int32_t espz_lcd_new_panel_io_spi(
    int32_t host_id,
    int32_t cs_io_num,
    int32_t dc_io_num,
    uint32_t pclk_hz,
    uint8_t spi_mode,
    uint8_t cmd_bits,
    uint8_t param_bits,
    uint32_t trans_queue_depth,
    void **out_handle);

int32_t espz_lcd_panel_io_del(void *io_handle);

int32_t espz_lcd_panel_io_tx_param(
    void *io_handle,
    uint32_t cmd,
    const void *params,
    size_t params_size);

int32_t espz_lcd_panel_io_tx_color(
    void *io_handle,
    uint32_t cmd,
    const void *colors,
    size_t color_size);

int32_t espz_lcd_panel_io_rx_param(
    void *io_handle,
    uint32_t cmd,
    void *out_params,
    size_t out_size);

int32_t espz_lcd_new_panel_st7789(
    void *io_handle,
    int32_t reset_gpio_num,
    uint32_t rgb_element_order,
    uint32_t data_endian,
    uint8_t bits_per_pixel,
    void **out_panel_handle);

int32_t espz_lcd_new_panel_ili9341(
    void *io_handle,
    int32_t reset_gpio_num,
    uint32_t rgb_element_order,
    uint32_t data_endian,
    uint8_t bits_per_pixel,
    void **out_panel_handle);

int32_t espz_lcd_panel_reset(void *panel);
int32_t espz_lcd_panel_init(void *panel);
int32_t espz_lcd_panel_del(void *panel);

int32_t espz_lcd_panel_draw_bitmap(
    void *panel,
    int32_t x_start,
    int32_t y_start,
    int32_t x_end,
    int32_t y_end,
    const void *color_data);

int32_t espz_lcd_panel_mirror(void *panel, bool mirror_x, bool mirror_y);
int32_t espz_lcd_panel_swap_xy(void *panel, bool enabled);
int32_t espz_lcd_panel_invert_color(void *panel, bool enabled);
int32_t espz_lcd_panel_set_gap(void *panel, int32_t x_gap, int32_t y_gap);
int32_t espz_lcd_panel_disp_on_off(void *panel, bool enabled);
int32_t espz_lcd_panel_disp_sleep(void *panel, bool enabled);
