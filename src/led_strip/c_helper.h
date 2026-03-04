#pragma once

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

int32_t espz_led_strip_new_rmt(
    int32_t gpio_num,
    uint32_t max_leds,
    uint32_t led_model,
    uint32_t color_component_format,
    bool invert_out,
    uint32_t resolution_hz,
    size_t mem_block_symbols,
    bool with_dma,
    void **out_handle);

int32_t espz_led_strip_new_spi(
    int32_t gpio_num,
    uint32_t max_leds,
    uint32_t led_model,
    uint32_t color_component_format,
    bool invert_out,
    int32_t spi_bus,
    bool with_dma,
    void **out_handle);

int32_t espz_led_strip_set_pixel(
    void *handle,
    uint32_t index,
    uint32_t red,
    uint32_t green,
    uint32_t blue);

int32_t espz_led_strip_set_pixel_rgbw(
    void *handle,
    uint32_t index,
    uint32_t red,
    uint32_t green,
    uint32_t blue,
    uint32_t white);

int32_t espz_led_strip_set_pixel_hsv(
    void *handle,
    uint32_t index,
    uint16_t hue,
    uint8_t saturation,
    uint8_t value);

int32_t espz_led_strip_refresh(void *handle);
int32_t espz_led_strip_clear(void *handle);
int32_t espz_led_strip_del(void *handle);
