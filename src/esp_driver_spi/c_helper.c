#include <stddef.h>
#include <stdint.h>

#include "driver/spi_master.h"
#include "esp_err.h"

#ifndef ESPZ_SPI_MAX_HOSTS
#define ESPZ_SPI_MAX_HOSTS 4
#endif

static spi_device_handle_t s_devices[ESPZ_SPI_MAX_HOSTS] = {0};

static int host_valid(int host_id)
{
    return host_id >= 0 && host_id < ESPZ_SPI_MAX_HOSTS;
}

int32_t espz_spi_master_init(
    int host_id,
    int mosi_io_num,
    int miso_io_num,
    int sclk_io_num,
    int cs_io_num,
    uint32_t clock_hz,
    uint8_t mode)
{
    if (!host_valid(host_id)) return ESP_ERR_INVALID_ARG;

    if (s_devices[host_id] != NULL) {
        return ESP_ERR_INVALID_STATE;
    }

    spi_bus_config_t bus_cfg = {
        .mosi_io_num = mosi_io_num,
        .miso_io_num = miso_io_num,
        .sclk_io_num = sclk_io_num,
        .quadwp_io_num = -1,
        .quadhd_io_num = -1,
        .max_transfer_sz = 4096,
    };

    esp_err_t err = spi_bus_initialize((spi_host_device_t)host_id, &bus_cfg, SPI_DMA_CH_AUTO);
    if (err != ESP_OK && err != ESP_ERR_INVALID_STATE) return err;

    spi_device_interface_config_t dev_cfg = {
        .clock_speed_hz = (int)clock_hz,
        .mode = mode,
        .spics_io_num = cs_io_num,
        .queue_size = 1,
    };

    err = spi_bus_add_device((spi_host_device_t)host_id, &dev_cfg, &s_devices[host_id]);
    return err;
}

int32_t espz_spi_master_deinit(int host_id)
{
    if (!host_valid(host_id)) return ESP_ERR_INVALID_ARG;
    if (s_devices[host_id] == NULL) return ESP_ERR_INVALID_STATE;

    esp_err_t err = spi_bus_remove_device(s_devices[host_id]);
    if (err != ESP_OK) return err;

    s_devices[host_id] = NULL;
    return spi_bus_free((spi_host_device_t)host_id);
}

int32_t espz_spi_master_write(int host_id, const uint8_t *data, size_t len, uint32_t timeout_ms)
{
    (void)timeout_ms;
    if (!host_valid(host_id)) return ESP_ERR_INVALID_ARG;
    if (s_devices[host_id] == NULL) return ESP_ERR_INVALID_STATE;
    if (len == 0) return ESP_OK;
    if (data == NULL) return ESP_ERR_INVALID_ARG;

    spi_transaction_t t = {
        .length = len * 8,
        .tx_buffer = data,
    };
    return spi_device_transmit(s_devices[host_id], &t);
}

int32_t espz_spi_master_transfer(int host_id, const uint8_t *tx, uint8_t *rx, size_t len, uint32_t timeout_ms)
{
    (void)timeout_ms;
    if (!host_valid(host_id)) return ESP_ERR_INVALID_ARG;
    if (s_devices[host_id] == NULL) return ESP_ERR_INVALID_STATE;
    if (len == 0) return ESP_OK;
    if (tx == NULL || rx == NULL) return ESP_ERR_INVALID_ARG;

    spi_transaction_t t = {
        .length = len * 8,
        .tx_buffer = tx,
        .rx_buffer = rx,
    };
    return spi_device_transmit(s_devices[host_id], &t);
}

int32_t espz_spi_master_read(int host_id, uint8_t *rx, size_t len, uint32_t timeout_ms)
{
    (void)timeout_ms;
    if (!host_valid(host_id)) return ESP_ERR_INVALID_ARG;
    if (s_devices[host_id] == NULL) return ESP_ERR_INVALID_STATE;
    if (len == 0) return ESP_OK;
    if (rx == NULL) return ESP_ERR_INVALID_ARG;

    spi_transaction_t t = {
        .length = len * 8,
        .rxlength = len * 8,
        .rx_buffer = rx,
    };
    return spi_device_transmit(s_devices[host_id], &t);
}
