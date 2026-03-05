#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/idf_additions.h"

/*
 * ADF compatibility shim:
 *
 * Some ADF/IDF combinations expect xTaskCreateRestrictedPinnedToCore().
 * Newer patched IDF may already provide it; keep this weak to avoid symbol
 * conflicts and let the native IDF implementation override when present.
 *
 * This shim maps restricted creation to dynamic pinned task creation.
 */
#if ( configSUPPORT_STATIC_ALLOCATION == 1 )
__attribute__((weak)) BaseType_t xTaskCreateRestrictedPinnedToCore(
    const TaskParameters_t * const pxTaskDefinition,
    TaskHandle_t * pxCreatedTask,
    const BaseType_t xCoreID)
{
#if ( configSUPPORT_DYNAMIC_ALLOCATION == 1 )
    if (pxTaskDefinition == NULL || pxTaskDefinition->pvTaskCode == NULL || pxTaskDefinition->pcName == NULL) {
        return errCOULD_NOT_ALLOCATE_REQUIRED_MEMORY;
    }

    return xTaskCreatePinnedToCore(
        pxTaskDefinition->pvTaskCode,
        pxTaskDefinition->pcName,
        pxTaskDefinition->usStackDepth,
        (void * const)pxTaskDefinition->pvParameters,
        pxTaskDefinition->uxPriority,
        pxCreatedTask,
        xCoreID);
#else
    (void)pxTaskDefinition;
    (void)pxCreatedTask;
    (void)xCoreID;
    return errCOULD_NOT_ALLOCATE_REQUIRED_MEMORY;
#endif
}
#endif
