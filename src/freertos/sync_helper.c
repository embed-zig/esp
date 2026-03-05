#include <stddef.h>
#include <stdint.h>

#include "freertos/FreeRTOS.h"
#include "freertos/semphr.h"

SemaphoreHandle_t espz_semaphore_create_mutex(void)
{
    return xSemaphoreCreateMutex();
}

SemaphoreHandle_t espz_semaphore_create_binary(void)
{
    return xSemaphoreCreateBinary();
}

SemaphoreHandle_t espz_semaphore_create_counting(uint32_t max_count, uint32_t initial_count)
{
    return xSemaphoreCreateCounting((UBaseType_t)max_count, (UBaseType_t)initial_count);
}

int32_t espz_semaphore_take(SemaphoreHandle_t handle, uint32_t ticks)
{
    return (int32_t)xSemaphoreTake(handle, (TickType_t)ticks);
}

int32_t espz_semaphore_give(SemaphoreHandle_t handle)
{
    return (int32_t)xSemaphoreGive(handle);
}

void espz_semaphore_delete(SemaphoreHandle_t handle)
{
    vSemaphoreDelete(handle);
}
