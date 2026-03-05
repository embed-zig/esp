#include <stddef.h>
#include <stdint.h>

#include "freertos/FreeRTOS.h"
#include "freertos/queue.h"

QueueHandle_t espz_queue_create(uint32_t length, uint32_t item_size)
{
    return xQueueCreate((UBaseType_t)length, (UBaseType_t)item_size);
}

int32_t espz_queue_send(QueueHandle_t q, const void *item, uint32_t ticks)
{
    return (int32_t)xQueueSend(q, item, (TickType_t)ticks);
}

int32_t espz_queue_receive(QueueHandle_t q, void *buffer, uint32_t ticks)
{
    return (int32_t)xQueueReceive(q, buffer, (TickType_t)ticks);
}

uint32_t espz_queue_messages_waiting(QueueHandle_t q)
{
    return (uint32_t)uxQueueMessagesWaiting(q);
}

void espz_queue_delete(QueueHandle_t q)
{
    vQueueDelete(q);
}

QueueSetHandle_t espz_queue_create_set(uint32_t length)
{
    return xQueueCreateSet((UBaseType_t)length);
}

int32_t espz_queue_add_to_set(QueueSetMemberHandle_t member, QueueSetHandle_t set)
{
    return (int32_t)xQueueAddToSet(member, set);
}

int32_t espz_queue_remove_from_set(QueueSetMemberHandle_t member, QueueSetHandle_t set)
{
    return (int32_t)xQueueRemoveFromSet(member, set);
}

QueueSetMemberHandle_t espz_queue_select_from_set(QueueSetHandle_t set, uint32_t ticks)
{
    return xQueueSelectFromSet(set, (TickType_t)ticks);
}
