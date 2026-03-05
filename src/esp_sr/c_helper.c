#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "esp_err.h"
#include "esp_log.h"
#include "esp_heap_caps.h"

/* ---------- AFE (Audio Front-end) ---------- */
#if __has_include("esp_afe_sr_iface.h")
#include "esp_afe_sr_iface.h"
#include "esp_afe_sr_models.h"
#define ESPZ_SR_HAS_AFE 1
#else
#define ESPZ_SR_HAS_AFE 0
#endif

/* ---------- Standalone AEC ---------- */
#if __has_include("esp_aec.h")
#include "esp_aec.h"
#define ESPZ_SR_HAS_AEC 1
#else
#define ESPZ_SR_HAS_AEC 0
#endif

/* ---------- Standalone NS ---------- */
#if __has_include("esp_ns.h")
#include "esp_ns.h"
#define ESPZ_SR_HAS_NS 1
#else
#define ESPZ_SR_HAS_NS 0
#endif

/* ---------- Standalone AGC ---------- */
#if __has_include("esp_agc.h")
#include "esp_agc.h"
#define ESPZ_SR_HAS_AGC 1
#else
#define ESPZ_SR_HAS_AGC 0
#endif

/* ---------- Standalone VAD ---------- */
#if __has_include("esp_vad.h")
#include "esp_vad.h"
#define ESPZ_SR_HAS_VAD 1
#else
#define ESPZ_SR_HAS_VAD 0
#endif

/* ---------- MASE (Mic Array Speech Enhancement) ---------- */
#if __has_include("esp_mase.h")
#include "esp_mase.h"
#define ESPZ_SR_HAS_MASE 1
#else
#define ESPZ_SR_HAS_MASE 0
#endif

/* ---------- MultiNet ---------- */
#if __has_include("esp_mn_iface.h")
#include "esp_mn_iface.h"
#include "esp_mn_models.h"
#define ESPZ_SR_HAS_MN 1
#else
#define ESPZ_SR_HAS_MN 0
#endif

/* ---------- Model loader ---------- */
#if __has_include("esp_srmodel_filter.h")
#include "esp_srmodel_filter.h"
#define ESPZ_SR_HAS_SRMODEL 1
#else
#define ESPZ_SR_HAS_SRMODEL 0
#endif

static const char *TAG = "espz_sr";

/* ================================================================
 * AFE shims
 * ================================================================ */
#if ESPZ_SR_HAS_AFE

static const esp_afe_sr_iface_t *s_afe_iface = NULL;
static esp_afe_sr_data_t *s_afe_data = NULL;

int32_t espz_sr_afe_create(
    int afe_type,
    int afe_mode,
    const char *input_format,
    int wakenet_en,
    int aec_en,
    int ns_en,
    int agc_en,
    int vad_en)
{
    if (s_afe_data != NULL) return ESP_ERR_INVALID_STATE;

#if ESPZ_SR_HAS_SRMODEL
    srmodel_list_t *models = esp_srmodel_init("model");
#else
    srmodel_list_t *models = NULL;
#endif

    afe_config_t *afe_config = afe_config_init(
        input_format, models, (afe_type_t)afe_type, (afe_mode_t)afe_mode);
    if (afe_config == NULL) {
        ESP_LOGE(TAG, "afe_config_init failed");
        return ESP_FAIL;
    }

    afe_config->wakenet_init = wakenet_en ? true : false;
    afe_config->aec_init = aec_en ? true : false;
    afe_config->se_init = ns_en ? true : false;
    afe_config->vad_init = vad_en ? true : false;
    afe_config->agc_init = agc_en ? true : false;

    s_afe_iface = esp_afe_handle_from_config(afe_config);
    if (s_afe_iface == NULL) {
        ESP_LOGE(TAG, "esp_afe_handle_from_config failed");
        afe_config_free(afe_config);
        return ESP_FAIL;
    }
    s_afe_data = s_afe_iface->create_from_config(afe_config);
    afe_config_free(afe_config);
    if (s_afe_data == NULL) {
        ESP_LOGE(TAG, "AFE create failed");
        s_afe_iface = NULL;
        return ESP_FAIL;
    }

    return ESP_OK;
}

int32_t espz_sr_afe_destroy(void)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;
    s_afe_iface->destroy(s_afe_data);
    s_afe_data = NULL;
    s_afe_iface = NULL;
    return ESP_OK;
}

int32_t espz_sr_afe_feed(const int16_t *audio, int len)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;
    int ret = s_afe_iface->feed(s_afe_data, audio);
    (void)len;
    return ret >= 0 ? ESP_OK : ESP_FAIL;
}

int32_t espz_sr_afe_fetch(
    int32_t *out_wakeup_state,
    int32_t *out_vad_state,
    int32_t *out_data_size,
    int16_t **out_data_ptr,
    int32_t *out_channel_id,
    int32_t ticks_to_wait)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;

    afe_fetch_result_t *result;
    if (ticks_to_wait >= 0) {
        result = s_afe_iface->fetch_with_delay(s_afe_data, (TickType_t)ticks_to_wait);
    } else {
        result = s_afe_iface->fetch(s_afe_data);
    }

    if (result == NULL) return ESP_FAIL;

    if (out_wakeup_state) *out_wakeup_state = (int32_t)result->wakeup_state;
    if (out_vad_state) *out_vad_state = (int32_t)result->vad_state;
    if (out_data_size) *out_data_size = result->data_size;
    if (out_data_ptr) *out_data_ptr = result->data;
    if (out_channel_id) *out_channel_id = result->trigger_channel_id;

    return ESP_OK;
}

int32_t espz_sr_afe_get_feed_chunksize(int32_t *out)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;
    *out = s_afe_iface->get_feed_chunksize(s_afe_data);
    return ESP_OK;
}

int32_t espz_sr_afe_get_channel_num(int32_t *out)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;
    *out = s_afe_iface->get_channel_num(s_afe_data);
    return ESP_OK;
}

int32_t espz_sr_afe_get_sample_rate(int32_t *out)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;
    *out = s_afe_iface->get_samp_rate(s_afe_data);
    return ESP_OK;
}

int32_t espz_sr_afe_enable_wakenet(void)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;
    return s_afe_iface->enable_wakenet(s_afe_data) >= 0 ? ESP_OK : ESP_FAIL;
}

int32_t espz_sr_afe_disable_wakenet(void)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;
    return s_afe_iface->disable_wakenet(s_afe_data) >= 0 ? ESP_OK : ESP_FAIL;
}

int32_t espz_sr_afe_enable_aec(void)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;
    return s_afe_iface->enable_aec(s_afe_data) >= 0 ? ESP_OK : ESP_FAIL;
}

int32_t espz_sr_afe_disable_aec(void)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;
    return s_afe_iface->disable_aec(s_afe_data) >= 0 ? ESP_OK : ESP_FAIL;
}

int32_t espz_sr_afe_enable_ns(void)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;
    return s_afe_iface->enable_se(s_afe_data) >= 0 ? ESP_OK : ESP_FAIL;
}

int32_t espz_sr_afe_disable_ns(void)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;
    return s_afe_iface->disable_se(s_afe_data) >= 0 ? ESP_OK : ESP_FAIL;
}

int32_t espz_sr_afe_enable_agc(void)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;
    return s_afe_iface->enable_agc(s_afe_data) >= 0 ? ESP_OK : ESP_FAIL;
}

int32_t espz_sr_afe_disable_agc(void)
{
    if (s_afe_iface == NULL || s_afe_data == NULL) return ESP_ERR_INVALID_STATE;
    return s_afe_iface->disable_agc(s_afe_data) >= 0 ? ESP_OK : ESP_FAIL;
}

#endif /* ESPZ_SR_HAS_AFE */

/* ================================================================
 * MASE shims
 * ================================================================ */
#if ESPZ_SR_HAS_MASE

void *espz_sr_mase_create(
    int sample_rate,
    int frame_size_ms,
    int array_type,
    float mic_distance,
    int operating_mode,
    int filter_strength)
{
    return mase_create(sample_rate, frame_size_ms, array_type, mic_distance, operating_mode, filter_strength);
}

int32_t espz_sr_mase_process(void *handle, int16_t *in, int16_t *dsp_out)
{
    if (handle == NULL) return ESP_ERR_INVALID_ARG;
    mase_process(handle, in, dsp_out);
    return ESP_OK;
}

void espz_sr_mase_destroy(void *handle)
{
    /* Note: upstream API is spelled "mase_destory" (sic). */
    if (handle != NULL) mase_destory(handle);
}

#endif /* ESPZ_SR_HAS_MASE */

/* ================================================================
 * Standalone AEC shims
 * ================================================================ */
#if ESPZ_SR_HAS_AEC

void *espz_sr_aec_create(int sample_rate, int frame_length, int channel_num, int mode)
{
    heap_caps_malloc_extmem_enable(0);
    void *h = aec_create(sample_rate, frame_length, channel_num, (aec_mode_t)mode);
    heap_caps_malloc_extmem_enable((size_t)-1);
    return h;
}

int32_t espz_sr_aec_process(void *handle, int16_t *indata, int16_t *refdata, int16_t *outdata)
{
    if (handle == NULL) return ESP_ERR_INVALID_ARG;
    aec_process(handle, indata, refdata, outdata);
    return ESP_OK;
}

int32_t espz_sr_aec_get_chunksize(void *handle, int32_t *out)
{
    if (handle == NULL || out == NULL) return ESP_ERR_INVALID_ARG;
    *out = aec_get_chunksize(handle);
    return ESP_OK;
}

void espz_sr_aec_destroy(void *handle)
{
    if (handle != NULL) aec_destroy(handle);
}

#endif /* ESPZ_SR_HAS_AEC */

/* ================================================================
 * Standalone NS shims
 * ================================================================ */
#if ESPZ_SR_HAS_NS

void *espz_sr_ns_create(int frame_length_ms)
{
    return ns_create(frame_length_ms);
}

void *espz_sr_ns_pro_create(int frame_length_ms, int mode, int sample_rate)
{
    return ns_pro_create(frame_length_ms, mode, sample_rate);
}

int32_t espz_sr_ns_process(void *handle, int16_t *indata, int16_t *outdata)
{
    if (handle == NULL) return ESP_ERR_INVALID_ARG;
    ns_process(handle, indata, outdata);
    return ESP_OK;
}

void espz_sr_ns_destroy(void *handle)
{
    if (handle != NULL) ns_destroy(handle);
}

#endif /* ESPZ_SR_HAS_NS */

/* ================================================================
 * Standalone AGC shims
 * ================================================================ */
#if ESPZ_SR_HAS_AGC

void *espz_sr_agc_open(int agc_mode, int sample_rate)
{
    return esp_agc_open(agc_mode, sample_rate);
}

int32_t espz_sr_agc_set_config(void *handle, int gain_db, int limiter_enable, int target_level_dbfs)
{
    if (handle == NULL) return ESP_ERR_INVALID_ARG;
    set_agc_config(handle, gain_db, limiter_enable, target_level_dbfs);
    return ESP_OK;
}

int32_t espz_sr_agc_process(void *handle, int16_t *in_pcm, int16_t *out_pcm, int frame_size, int sample_rate)
{
    if (handle == NULL) return ESP_ERR_INVALID_ARG;
    int ret = esp_agc_process(handle, in_pcm, out_pcm, frame_size, sample_rate);
    return ret == 0 ? ESP_OK : ESP_FAIL;
}

void espz_sr_agc_close(void *handle)
{
    if (handle != NULL) esp_agc_close(handle);
}

#endif /* ESPZ_SR_HAS_AGC */

/* ================================================================
 * Standalone VAD shims
 * ================================================================ */
#if ESPZ_SR_HAS_VAD

void *espz_sr_vad_create(int vad_mode)
{
    return vad_create((vad_mode_t)vad_mode);
}

void *espz_sr_vad_create_with_param(
    int vad_mode,
    int sample_rate,
    int one_frame_ms,
    int min_speech_ms,
    int min_noise_ms)
{
    return vad_create_with_param(
        (vad_mode_t)vad_mode,
        sample_rate,
        one_frame_ms,
        min_speech_ms,
        min_noise_ms);
}

int32_t espz_sr_vad_process(void *handle, int16_t *data, int sample_rate, int one_frame_ms, int32_t *out_state)
{
    if (handle == NULL || out_state == NULL) return ESP_ERR_INVALID_ARG;
    *out_state = (int32_t)vad_process(handle, data, sample_rate, one_frame_ms);
    return ESP_OK;
}

void espz_sr_vad_destroy(void *handle)
{
    if (handle != NULL) vad_destroy(handle);
}

#endif /* ESPZ_SR_HAS_VAD */

/* ================================================================
 * MultiNet shims
 * ================================================================ */
#if ESPZ_SR_HAS_MN

static const esp_mn_iface_t *s_mn_iface = NULL;
static model_iface_data_t *s_mn_data = NULL;

int32_t espz_sr_mn_create(const char *model_name, int duration_ms)
{
    if (s_mn_data != NULL) return ESP_ERR_INVALID_STATE;

    s_mn_iface = esp_mn_handle_from_name(model_name);
    if (s_mn_iface == NULL) {
        ESP_LOGE(TAG, "MultiNet model not found: %s", model_name ? model_name : "(null)");
        return ESP_ERR_NOT_FOUND;
    }

    s_mn_data = s_mn_iface->create(model_name, duration_ms);
    if (s_mn_data == NULL) {
        ESP_LOGE(TAG, "MultiNet create failed");
        s_mn_iface = NULL;
        return ESP_FAIL;
    }

    return ESP_OK;
}

int32_t espz_sr_mn_destroy(void)
{
    if (s_mn_iface == NULL || s_mn_data == NULL) return ESP_ERR_INVALID_STATE;
    s_mn_iface->destroy(s_mn_data);
    s_mn_data = NULL;
    s_mn_iface = NULL;
    return ESP_OK;
}

int32_t espz_sr_mn_detect(int16_t *samples, int32_t *out_state)
{
    if (s_mn_iface == NULL || s_mn_data == NULL) return ESP_ERR_INVALID_STATE;
    if (out_state == NULL) return ESP_ERR_INVALID_ARG;
    *out_state = (int32_t)s_mn_iface->detect(s_mn_data, samples);
    return ESP_OK;
}

int32_t espz_sr_mn_get_results(
    int32_t *out_command_id,
    float *out_prob,
    const char **out_string)
{
    if (s_mn_iface == NULL || s_mn_data == NULL) return ESP_ERR_INVALID_STATE;
    esp_mn_results_t *results = s_mn_iface->get_results(s_mn_data);
    if (results == NULL) return ESP_FAIL;

    if (out_command_id) *out_command_id = results->command_id[0];
    if (out_prob) *out_prob = results->prob[0];
    if (out_string) *out_string = results->string;

    return ESP_OK;
}

int32_t espz_sr_mn_get_chunksize(int32_t *out)
{
    if (s_mn_iface == NULL || s_mn_data == NULL) return ESP_ERR_INVALID_STATE;
    if (out == NULL) return ESP_ERR_INVALID_ARG;
    *out = s_mn_iface->get_samp_chunksize(s_mn_data);
    return ESP_OK;
}

static esp_mn_node_t *s_mn_cmd_head = NULL;

int32_t espz_sr_mn_commands_add(int command_id, const char *phrase)
{
    esp_mn_node_t *node = (esp_mn_node_t *)malloc(sizeof(esp_mn_node_t));
    if (node == NULL) return ESP_ERR_NO_MEM;
    esp_mn_phrase_t *p = (esp_mn_phrase_t *)calloc(1, sizeof(esp_mn_phrase_t));
    if (p == NULL) { free(node); return ESP_ERR_NO_MEM; }
    p->command_id = (int16_t)command_id;
    p->string = strdup(phrase);
    if (p->string == NULL) { free(p); free(node); return ESP_ERR_NO_MEM; }
    node->phrase = p;
    node->next = s_mn_cmd_head;
    s_mn_cmd_head = node;
    return ESP_OK;
}

int32_t espz_sr_mn_commands_update(void)
{
    if (s_mn_iface == NULL || s_mn_data == NULL) return ESP_ERR_INVALID_STATE;
    esp_mn_error_t *err = s_mn_iface->set_speech_commands(s_mn_data, s_mn_cmd_head);
    (void)err;
    return ESP_OK;
}

int32_t espz_sr_mn_commands_clear(void)
{
    while (s_mn_cmd_head != NULL) {
        esp_mn_node_t *next = s_mn_cmd_head->next;
        if (s_mn_cmd_head->phrase) {
            free(s_mn_cmd_head->phrase->string);
            free(s_mn_cmd_head->phrase);
        }
        free(s_mn_cmd_head);
        s_mn_cmd_head = next;
    }
    return ESP_OK;
}

#endif /* ESPZ_SR_HAS_MN */
