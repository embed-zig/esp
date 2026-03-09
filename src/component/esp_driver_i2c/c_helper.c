#include <stddef.h>
#include <stdint.h>

#include "driver/i2c.h"
#include "esp_err.h"
#include "freertos/FreeRTOS.h"

int32_t espz_i2c_master_init(int port, int sda, int scl, uint32_t freq_hz)
{
    i2c_config_t conf = {
        .mode = I2C_MODE_MASTER,
        .sda_io_num = sda,
        .sda_pullup_en = GPIO_PULLUP_ENABLE,
        .scl_io_num = scl,
        .scl_pullup_en = GPIO_PULLUP_ENABLE,
        .master.clk_speed = freq_hz,
    };
    esp_err_t err = i2c_param_config(port, &conf);
    if (err != ESP_OK) return err;
    return i2c_driver_install(port, conf.mode, 0, 0, 0);
}

int32_t espz_i2c_master_write_to_device(
    int port, uint8_t addr,
    const uint8_t *data, size_t len,
    uint32_t timeout_ms)
{
    return i2c_master_write_to_device(port, addr, data, len, pdMS_TO_TICKS(timeout_ms));
}

int32_t espz_i2c_master_write_read_device(
    int port, uint8_t addr,
    const uint8_t *write_data, size_t write_len,
    uint8_t *read_data, size_t read_len,
    uint32_t timeout_ms)
{
    return i2c_master_write_read_device(
        port, addr,
        write_data, write_len,
        read_data, read_len,
        pdMS_TO_TICKS(timeout_ms));
}
