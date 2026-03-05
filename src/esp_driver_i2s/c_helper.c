#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#include "driver/i2s_std.h"
#include "driver/i2s_tdm.h"
#include "esp_err.h"
#include "freertos/FreeRTOS.h"

#ifndef ESPZ_I2S_MAX_PORTS
#define ESPZ_I2S_MAX_PORTS 2
#endif

#if defined(I2S_STD_MSB_SLOT_DEFAULT_CONFIG)
#define ESPZ_I2S_STD_SLOT(bits, mode) I2S_STD_MSB_SLOT_DEFAULT_CONFIG(bits, mode)
#else
#define ESPZ_I2S_STD_SLOT(bits, mode) I2S_STD_PHILIPS_SLOT_DEFAULT_CONFIG(bits, mode)
#endif

#if defined(I2S_TDM_MSB_SLOT_DEFAULT_CONFIG)
#define ESPZ_I2S_TDM_SLOT(bits, mode, mask) I2S_TDM_MSB_SLOT_DEFAULT_CONFIG(bits, mode, mask)
#else
#define ESPZ_I2S_TDM_SLOT(bits, mode, mask) I2S_TDM_PHILIPS_SLOT_DEFAULT_CONFIG(bits, mode, mask)
#endif

static i2s_chan_handle_t s_rx[ESPZ_I2S_MAX_PORTS];
static i2s_chan_handle_t s_tx[ESPZ_I2S_MAX_PORTS];

static int port_ok(int p) { return p >= 0 && p < ESPZ_I2S_MAX_PORTS; }

static i2s_role_t to_role(int r) { return r == 1 ? I2S_ROLE_SLAVE : I2S_ROLE_MASTER; }

static i2s_data_bit_width_t to_bits(uint32_t b)
{
    switch (b) {
    case 16: return I2S_DATA_BIT_WIDTH_16BIT;
    case 24: return I2S_DATA_BIT_WIDTH_24BIT;
    case 32: return I2S_DATA_BIT_WIDTH_32BIT;
    default: return I2S_DATA_BIT_WIDTH_16BIT;
    }
}

static i2s_slot_mode_t to_slot(uint32_t m)
{
    return m == 2 ? I2S_SLOT_MODE_STEREO : I2S_SLOT_MODE_MONO;
}

/* ── internal: configure + enable one channel in STD or TDM mode ── */

static esp_err_t init_std_channel(
    i2s_chan_handle_t ch,
    uint32_t sample_rate,
    uint32_t bits,
    uint32_t slot_mode,
    int mclk, int bclk, int ws,
    int din, int dout)
{
    i2s_std_config_t cfg = {
        .clk_cfg  = I2S_STD_CLK_DEFAULT_CONFIG(sample_rate),
        .slot_cfg = ESPZ_I2S_STD_SLOT(to_bits(bits), to_slot(slot_mode)),
        .gpio_cfg = {
            .mclk = mclk,
            .bclk = bclk,
            .ws   = ws,
            .din  = din  >= 0 ? din  : I2S_GPIO_UNUSED,
            .dout = dout >= 0 ? dout : I2S_GPIO_UNUSED,
            .invert_flags = { .mclk_inv = false, .bclk_inv = false, .ws_inv = false },
        },
    };
    return i2s_channel_init_std_mode(ch, &cfg);
}

static esp_err_t init_tdm_channel(
    i2s_chan_handle_t ch,
    uint32_t sample_rate,
    uint32_t bits,
    uint32_t slot_mode,
    uint32_t tdm_mask,
    int mclk, int bclk, int ws,
    int din, int dout)
{
    if (tdm_mask == 0) return ESP_ERR_INVALID_ARG;
    i2s_tdm_config_t cfg = {
        .clk_cfg  = I2S_TDM_CLK_DEFAULT_CONFIG(sample_rate),
        .slot_cfg = ESPZ_I2S_TDM_SLOT(to_bits(bits), to_slot(slot_mode),
                                       (i2s_tdm_slot_mask_t)tdm_mask),
        .gpio_cfg = {
            .mclk = mclk,
            .bclk = bclk,
            .ws   = ws,
            .din  = din  >= 0 ? din  : I2S_GPIO_UNUSED,
            .dout = dout >= 0 ? dout : I2S_GPIO_UNUSED,
            .invert_flags = { .mclk_inv = false, .bclk_inv = false, .ws_inv = false },
        },
    };
    return i2s_channel_init_tdm_mode(ch, &cfg);
}

static esp_err_t configure_and_enable(
    i2s_chan_handle_t ch,
    uint32_t mode_tdm,
    uint32_t sample_rate,
    uint32_t bits,
    uint32_t slot_mode,
    uint32_t tdm_mask,
    int mclk, int bclk, int ws,
    int din, int dout)
{
    esp_err_t err;
    if (mode_tdm) {
        err = init_tdm_channel(ch, sample_rate, bits, slot_mode, tdm_mask,
                               mclk, bclk, ws, din, dout);
    } else {
        err = init_std_channel(ch, sample_rate, bits, slot_mode,
                               mclk, bclk, ws, din, dout);
    }
    if (err != ESP_OK) return err;
    return i2s_channel_enable(ch);
}

/* ================================================================
 * Simplex RX
 * ================================================================ */

int32_t espz_i2s_rx_init(
    int port, int role,
    uint32_t sample_rate, uint32_t bits, uint32_t mode_tdm,
    uint32_t slot_mode, uint32_t tdm_mask,
    int mclk, int bclk, int ws, int din,
    uint32_t dma_desc_num, uint32_t dma_frame_num)
{
    if (!port_ok(port)) return ESP_ERR_INVALID_ARG;
    if (bclk < 0 || ws < 0 || din < 0) return ESP_ERR_INVALID_ARG;
    if (s_rx[port] != NULL) return ESP_ERR_INVALID_STATE;

    i2s_chan_config_t cc = I2S_CHANNEL_DEFAULT_CONFIG((i2s_port_t)port, to_role(role));
    cc.dma_desc_num  = dma_desc_num;
    cc.dma_frame_num = dma_frame_num;

    i2s_chan_handle_t rx = NULL;
    esp_err_t err = i2s_new_channel(&cc, NULL, &rx);
    if (err != ESP_OK) return err;

    err = configure_and_enable(rx, mode_tdm, sample_rate, bits, slot_mode,
                               tdm_mask, mclk, bclk, ws, din, -1);
    if (err != ESP_OK) { i2s_del_channel(rx); return err; }

    s_rx[port] = rx;
    return ESP_OK;
}

int32_t espz_i2s_rx_deinit(int port)
{
    if (!port_ok(port) || s_rx[port] == NULL) return ESP_ERR_INVALID_STATE;
    i2s_channel_disable(s_rx[port]);
    esp_err_t err = i2s_del_channel(s_rx[port]);
    if (err != ESP_OK) return err;
    s_rx[port] = NULL;
    return ESP_OK;
}

int32_t espz_i2s_rx_read(int port, uint8_t *out, size_t len,
                          uint32_t timeout_ms, size_t *out_bytes)
{
    if (!port_ok(port) || s_rx[port] == NULL) return ESP_ERR_INVALID_STATE;
    if (!out || !out_bytes) return ESP_ERR_INVALID_ARG;
    if (len == 0) { *out_bytes = 0; return ESP_OK; }
    size_t n = 0;
    esp_err_t err = i2s_channel_read(s_rx[port], out, len, &n,
                                     pdMS_TO_TICKS(timeout_ms));
    if (err != ESP_OK) return err;
    *out_bytes = n;
    return ESP_OK;
}

/* ================================================================
 * Simplex TX
 * ================================================================ */

int32_t espz_i2s_tx_init(
    int port, int role,
    uint32_t sample_rate, uint32_t bits, uint32_t mode_tdm,
    uint32_t slot_mode, uint32_t tdm_mask,
    int mclk, int bclk, int ws, int dout,
    uint32_t dma_desc_num, uint32_t dma_frame_num)
{
    if (!port_ok(port)) return ESP_ERR_INVALID_ARG;
    if (bclk < 0 || ws < 0 || dout < 0) return ESP_ERR_INVALID_ARG;
    if (s_tx[port] != NULL) return ESP_ERR_INVALID_STATE;

    i2s_chan_config_t cc = I2S_CHANNEL_DEFAULT_CONFIG((i2s_port_t)port, to_role(role));
    cc.dma_desc_num  = dma_desc_num;
    cc.dma_frame_num = dma_frame_num;

    i2s_chan_handle_t tx = NULL;
    esp_err_t err = i2s_new_channel(&cc, &tx, NULL);
    if (err != ESP_OK) return err;

    err = configure_and_enable(tx, mode_tdm, sample_rate, bits, slot_mode,
                               tdm_mask, mclk, bclk, ws, -1, dout);
    if (err != ESP_OK) { i2s_del_channel(tx); return err; }

    s_tx[port] = tx;
    return ESP_OK;
}

int32_t espz_i2s_tx_deinit(int port)
{
    if (!port_ok(port) || s_tx[port] == NULL) return ESP_ERR_INVALID_STATE;
    i2s_channel_disable(s_tx[port]);
    esp_err_t err = i2s_del_channel(s_tx[port]);
    if (err != ESP_OK) return err;
    s_tx[port] = NULL;
    return ESP_OK;
}

int32_t espz_i2s_tx_write(int port, const uint8_t *in, size_t len,
                           uint32_t timeout_ms, size_t *out_bytes)
{
    if (!port_ok(port) || s_tx[port] == NULL) return ESP_ERR_INVALID_STATE;
    if (!in || !out_bytes) return ESP_ERR_INVALID_ARG;
    if (len == 0) { *out_bytes = 0; return ESP_OK; }
    size_t n = 0;
    esp_err_t err = i2s_channel_write(s_tx[port], in, len, &n,
                                      pdMS_TO_TICKS(timeout_ms));
    if (err != ESP_OK) return err;
    *out_bytes = n;
    return ESP_OK;
}

/* ================================================================
 * Full-duplex: allocate RX+TX on the same port in one call
 * ================================================================ */

int32_t espz_i2s_duplex_init(
    int port, int role,
    /* RX params */
    uint32_t rx_sample_rate, uint32_t rx_bits, uint32_t rx_mode_tdm,
    uint32_t rx_slot_mode, uint32_t rx_tdm_mask,
    int rx_mclk, int rx_bclk, int rx_ws, int rx_din,
    uint32_t rx_dma_desc_num, uint32_t rx_dma_frame_num,
    /* TX params */
    uint32_t tx_sample_rate, uint32_t tx_bits, uint32_t tx_mode_tdm,
    uint32_t tx_slot_mode, uint32_t tx_tdm_mask,
    int tx_mclk, int tx_bclk, int tx_ws, int tx_dout,
    uint32_t tx_dma_desc_num, uint32_t tx_dma_frame_num)
{
    if (!port_ok(port)) return ESP_ERR_INVALID_ARG;
    if (rx_din < 0 || tx_dout < 0) return ESP_ERR_INVALID_ARG;
    if (s_rx[port] != NULL || s_tx[port] != NULL) return ESP_ERR_INVALID_STATE;

    /* Use RX DMA params for the shared channel config; TX DMA is set per-channel
       internally by ESP-IDF when both handles are allocated together. */
    i2s_chan_config_t cc = I2S_CHANNEL_DEFAULT_CONFIG((i2s_port_t)port, to_role(role));
    cc.dma_desc_num  = rx_dma_desc_num > tx_dma_desc_num ? rx_dma_desc_num : tx_dma_desc_num;
    cc.dma_frame_num = rx_dma_frame_num > tx_dma_frame_num ? rx_dma_frame_num : tx_dma_frame_num;

    i2s_chan_handle_t tx = NULL, rx = NULL;
    esp_err_t err = i2s_new_channel(&cc, &tx, &rx);
    if (err != ESP_OK) return err;

    /* Configure + enable RX */
    err = configure_and_enable(rx, rx_mode_tdm, rx_sample_rate, rx_bits,
                               rx_slot_mode, rx_tdm_mask,
                               rx_mclk, rx_bclk, rx_ws, rx_din, -1);
    if (err != ESP_OK) {
        i2s_del_channel(rx);
        i2s_del_channel(tx);
        return err;
    }

    /* Configure + enable TX */
    err = configure_and_enable(tx, tx_mode_tdm, tx_sample_rate, tx_bits,
                               tx_slot_mode, tx_tdm_mask,
                               tx_mclk, tx_bclk, tx_ws, -1, tx_dout);
    if (err != ESP_OK) {
        i2s_channel_disable(rx);
        i2s_del_channel(rx);
        i2s_del_channel(tx);
        return err;
    }

    s_rx[port] = rx;
    s_tx[port] = tx;
    return ESP_OK;
}

int32_t espz_i2s_duplex_deinit(int port)
{
    if (!port_ok(port)) return ESP_ERR_INVALID_ARG;
    if (s_rx[port] == NULL && s_tx[port] == NULL) return ESP_ERR_INVALID_STATE;

    if (s_rx[port]) {
        i2s_channel_disable(s_rx[port]);
        i2s_del_channel(s_rx[port]);
        s_rx[port] = NULL;
    }
    if (s_tx[port]) {
        i2s_channel_disable(s_tx[port]);
        i2s_del_channel(s_tx[port]);
        s_tx[port] = NULL;
    }
    return ESP_OK;
}
