pub extern fn esp_get_free_heap_size() u32;
pub extern fn esp_get_minimum_free_heap_size() u32;
pub extern fn esp_get_free_internal_heap_size() u32;

pub fn freeHeapSize() u32 {
    return esp_get_free_heap_size();
}

pub fn minimumFreeHeapSize() u32 {
    return esp_get_minimum_free_heap_size();
}

pub fn freeInternalHeapSize() u32 {
    return esp_get_free_internal_heap_size();
}
