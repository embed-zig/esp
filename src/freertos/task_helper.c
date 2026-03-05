#include <stddef.h>
#include <stdint.h>

#include "freertos/FreeRTOS.h"
#include "freertos/idf_additions.h"
#include "freertos/task.h"
#include "esp_heap_caps.h"

static uint32_t espz_stack_words_from_bytes(uint32_t bytes)
{
    const uint32_t word = (uint32_t)sizeof(StackType_t);
    if (bytes == 0 || word == 0) {
        return 0;
    }
    return (bytes + word - 1U) / word;
}

int32_t espz_freertos_create_restricted_pinned(
    TaskFunction_t task_fn,
    const char *name,
    uint32_t stack_size_bytes,
    uint8_t *stack_buffer,
    void *ctx,
    uint32_t priority,
    TaskHandle_t *out_handle,
    int32_t core_id)
{
#if ( configSUPPORT_STATIC_ALLOCATION == 1 )
    if (task_fn == NULL || name == NULL || stack_buffer == NULL || out_handle == NULL) {
        return errCOULD_NOT_ALLOCATE_REQUIRED_MEMORY;
    }

    TaskParameters_t params = {0};
    params.pvTaskCode = task_fn;
    params.pcName = name;
    params.usStackDepth = espz_stack_words_from_bytes(stack_size_bytes);
    params.puxStackBuffer = (StackType_t *)stack_buffer;
    params.pvParameters = ctx;
    params.uxPriority = (UBaseType_t)priority;
    return xTaskCreateRestrictedPinnedToCore(&params, out_handle, (BaseType_t)core_id);
#else
    (void)task_fn;
    (void)name;
    (void)stack_size_bytes;
    (void)stack_buffer;
    (void)ctx;
    (void)priority;
    (void)out_handle;
    (void)core_id;
    return errCOULD_NOT_ALLOCATE_REQUIRED_MEMORY;
#endif
}

TaskHandle_t espz_freertos_create_static_pinned(
    TaskFunction_t task_fn,
    const char *name,
    uint32_t stack_size_bytes,
    uint8_t *stack_buffer,
    void *ctx,
    uint32_t priority,
    void *task_buffer,
    int32_t core_id)
{
#if ( configSUPPORT_STATIC_ALLOCATION == 1 )
    if (task_fn == NULL || name == NULL || stack_buffer == NULL || task_buffer == NULL) {
        return NULL;
    }

    return xTaskCreateStaticPinnedToCore(
        task_fn,
        name,
        espz_stack_words_from_bytes(stack_size_bytes),
        ctx,
        (UBaseType_t)priority,
        (StackType_t *)stack_buffer,
        (StaticTask_t *)task_buffer,
        (BaseType_t)core_id);
#else
    (void)task_fn;
    (void)name;
    (void)stack_size_bytes;
    (void)stack_buffer;
    (void)ctx;
    (void)priority;
    (void)task_buffer;
    (void)core_id;
    return NULL;
#endif
}

void *espz_freertos_heap_caps_malloc(size_t size, uint32_t caps)
{
    return heap_caps_malloc(size, (uint32_t)caps);
}

void espz_freertos_heap_caps_free(void *ptr)
{
    heap_caps_free(ptr);
}

uint32_t espz_freertos_malloc_cap_spiram(void)
{
    return (uint32_t)MALLOC_CAP_SPIRAM;
}

uint32_t espz_freertos_malloc_cap_internal(void)
{
    return (uint32_t)MALLOC_CAP_INTERNAL;
}

uint32_t espz_freertos_malloc_cap_8bit(void)
{
    return (uint32_t)MALLOC_CAP_8BIT;
}
