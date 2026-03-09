#include <stddef.h>
#include <stdint.h>

#include "driver/uart.h"
#include "esp_err.h"
#include "freertos/FreeRTOS.h"

int32_t espz_uart_init(
    int port,
    int tx_pin,
    int rx_pin,
    uint32_t baud_rate,
    size_t rx_buffer_size,
    size_t tx_buffer_size)
{
    uart_config_t cfg = {
        .baud_rate = (int)baud_rate,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
        .source_clk = UART_SCLK_DEFAULT,
    };

    esp_err_t err = uart_param_config((uart_port_t)port, &cfg);
    if (err != ESP_OK) return err;

    err = uart_set_pin((uart_port_t)port, tx_pin, rx_pin, UART_PIN_NO_CHANGE, UART_PIN_NO_CHANGE);
    if (err != ESP_OK) return err;

    return uart_driver_install((uart_port_t)port, (int)rx_buffer_size, (int)tx_buffer_size, 0, NULL, 0);
}

int32_t espz_uart_deinit(int port)
{
    return uart_driver_delete((uart_port_t)port);
}

int32_t espz_uart_read(int port, uint8_t *out, size_t len, uint32_t timeout_ms, int32_t *out_read_len)
{
    if (out == NULL || out_read_len == NULL) return ESP_ERR_INVALID_ARG;

    int n = uart_read_bytes((uart_port_t)port, out, (uint32_t)len, pdMS_TO_TICKS(timeout_ms));
    if (n < 0) return ESP_FAIL;
    *out_read_len = n;
    return ESP_OK;
}

int32_t espz_uart_write(int port, const uint8_t *data, size_t len, uint32_t timeout_ms, int32_t *out_written_len)
{
    (void)timeout_ms;
    if (data == NULL || out_written_len == NULL) return ESP_ERR_INVALID_ARG;

    int n = uart_write_bytes((uart_port_t)port, (const char *)data, len);
    if (n < 0) return ESP_FAIL;
    *out_written_len = n;
    return ESP_OK;
}

int32_t espz_uart_buffered_len(int port, size_t *out_len)
{
    if (out_len == NULL) return ESP_ERR_INVALID_ARG;
    return uart_get_buffered_data_len((uart_port_t)port, out_len);
}
