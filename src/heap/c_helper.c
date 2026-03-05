#include <stdlib.h>
#include <stddef.h>
#include <stdint.h>
#include "esp_heap_caps.h"

void *espz_heap_caps_malloc(size_t size, uint32_t caps)
{
    return heap_caps_malloc(size, caps);
}

void *espz_heap_caps_realloc(void *ptr, size_t size, uint32_t caps)
{
    return heap_caps_realloc(ptr, size, caps);
}

void espz_heap_caps_free(void *ptr)
{
    heap_caps_free(ptr);
}

void *espz_heap_malloc(size_t size)
{
    return malloc(size);
}

void *espz_heap_realloc(void *ptr, size_t size)
{
    return realloc(ptr, size);
}

void espz_heap_free(void *ptr)
{
    free(ptr);
}

uint32_t espz_heap_cap_exec(void)        { return (uint32_t)MALLOC_CAP_EXEC; }
uint32_t espz_heap_cap_32bit(void)       { return (uint32_t)MALLOC_CAP_32BIT; }
uint32_t espz_heap_cap_8bit(void)        { return (uint32_t)MALLOC_CAP_8BIT; }
uint32_t espz_heap_cap_dma(void)         { return (uint32_t)MALLOC_CAP_DMA; }
uint32_t espz_heap_cap_spiram(void)      { return (uint32_t)MALLOC_CAP_SPIRAM; }
uint32_t espz_heap_cap_internal(void)    { return (uint32_t)MALLOC_CAP_INTERNAL; }
uint32_t espz_heap_cap_default(void)     { return (uint32_t)MALLOC_CAP_DEFAULT; }
uint32_t espz_heap_cap_iram_8bit(void)   { return (uint32_t)MALLOC_CAP_IRAM_8BIT; }
uint32_t espz_heap_cap_retention(void)   { return (uint32_t)MALLOC_CAP_RETENTION; }
uint32_t espz_heap_cap_rtc(void)
{
#ifdef MALLOC_CAP_RTCRAM
    return (uint32_t)MALLOC_CAP_RTCRAM;
#else
    return 0;
#endif
}

size_t espz_heap_caps_get_free_size(uint32_t caps)
{
    return heap_caps_get_free_size(caps);
}

size_t espz_heap_caps_get_total_size(uint32_t caps)
{
    return heap_caps_get_total_size(caps);
}

size_t espz_heap_caps_get_minimum_free_size(uint32_t caps)
{
    return heap_caps_get_minimum_free_size(caps);
}
