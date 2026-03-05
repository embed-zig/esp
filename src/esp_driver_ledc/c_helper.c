#include <stdint.h>

#include "driver/ledc.h"
#include "esp_err.h"

static int s_fade_installed = 0;

static int clamp_percent(int percent)
{
    if (percent < 0) return 0;
    if (percent > 100) return 100;
    return percent;
}

static esp_err_t duty_from_percent(uint8_t duty_resolution_bits, int percent, uint32_t *duty_out)
{
    if (duty_resolution_bits == 0 || duty_resolution_bits > 20) {
        return ESP_ERR_INVALID_ARG;
    }
    const int clamped = clamp_percent(percent);
    const uint32_t max_duty = (uint32_t)((1ULL << duty_resolution_bits) - 1ULL);
    *duty_out = (uint32_t)(((uint64_t)max_duty * (uint64_t)clamped) / 100ULL);
    return ESP_OK;
}

int32_t espz_ledc_timer_config(
    int speed_mode,
    int timer_num,
    uint8_t duty_resolution_bits,
    uint32_t freq_hz,
    int clk_cfg)
{
    ledc_timer_config_t timer = {
        .speed_mode = (ledc_mode_t)speed_mode,
        .duty_resolution = (ledc_timer_bit_t)duty_resolution_bits,
        .timer_num = (ledc_timer_t)timer_num,
        .freq_hz = freq_hz,
        .clk_cfg = (ledc_clk_cfg_t)clk_cfg,
    };
    return ledc_timer_config(&timer);
}

int32_t espz_ledc_channel_config(
    int gpio,
    int speed_mode,
    int channel,
    int timer_num,
    int invert)
{
    ledc_channel_config_t ch_cfg = {
        .gpio_num = gpio,
        .speed_mode = (ledc_mode_t)speed_mode,
        .channel = (ledc_channel_t)channel,
        .intr_type = LEDC_INTR_DISABLE,
        .timer_sel = (ledc_timer_t)timer_num,
        .duty = 0,
        .hpoint = 0,
    };
    ch_cfg.flags.output_invert = invert ? 1 : 0;
    return ledc_channel_config(&ch_cfg);
}

int32_t espz_ledc_set_duty(int speed_mode, int channel, uint32_t duty)
{
    return ledc_set_duty((ledc_mode_t)speed_mode, (ledc_channel_t)channel, duty);
}

int32_t espz_ledc_update_duty(int speed_mode, int channel)
{
    return ledc_update_duty((ledc_mode_t)speed_mode, (ledc_channel_t)channel);
}

int32_t espz_ledc_set_duty_percent(
    int speed_mode,
    int channel,
    uint8_t duty_resolution_bits,
    int percent)
{
    uint32_t duty = 0;
    esp_err_t err = duty_from_percent(duty_resolution_bits, percent, &duty);
    if (err != ESP_OK) return err;

    err = ledc_set_duty((ledc_mode_t)speed_mode, (ledc_channel_t)channel, duty);
    if (err != ESP_OK) return err;
    return ledc_update_duty((ledc_mode_t)speed_mode, (ledc_channel_t)channel);
}

int32_t espz_ledc_fade_install(void)
{
    if (s_fade_installed) return ESP_OK;
    esp_err_t err = ledc_fade_func_install(0);
    if (err == ESP_OK) {
        s_fade_installed = 1;
    }
    return err;
}

int32_t espz_ledc_fade_to_duty(
    int speed_mode,
    int channel,
    uint32_t duty,
    uint32_t duration_ms,
    int wait_done)
{
    esp_err_t err = ledc_set_fade_with_time(
        (ledc_mode_t)speed_mode,
        (ledc_channel_t)channel,
        duty,
        duration_ms);
    if (err != ESP_OK) return err;

    return ledc_fade_start(
        (ledc_mode_t)speed_mode,
        (ledc_channel_t)channel,
        wait_done ? LEDC_FADE_WAIT_DONE : LEDC_FADE_NO_WAIT);
}

int32_t espz_ledc_fade_to_percent(
    int speed_mode,
    int channel,
    uint8_t duty_resolution_bits,
    int percent,
    uint32_t duration_ms,
    int wait_done)
{
    uint32_t duty = 0;
    esp_err_t err = duty_from_percent(duty_resolution_bits, percent, &duty);
    if (err != ESP_OK) return err;
    return espz_ledc_fade_to_duty(speed_mode, channel, duty, duration_ms, wait_done);
}
