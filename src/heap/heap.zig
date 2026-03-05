extern fn espz_heap_caps_malloc(size: usize, caps: u32) ?[*]u8;
extern fn espz_heap_caps_free(ptr: ?*anyopaque) void;
extern fn espz_heap_caps_get_free_size(caps: u32) usize;
extern fn espz_heap_caps_get_total_size(caps: u32) usize;
extern fn espz_heap_caps_get_minimum_free_size(caps: u32) usize;

extern fn esp_get_free_heap_size() u32;
extern fn esp_get_minimum_free_heap_size() u32;
extern fn esp_get_free_internal_heap_size() u32;

pub fn freeHeapSize() u32 {
    return esp_get_free_heap_size();
}

pub fn minimumFreeHeapSize() u32 {
    return esp_get_minimum_free_heap_size();
}

pub fn freeInternalHeapSize() u32 {
    return esp_get_free_internal_heap_size();
}

pub fn capsGetFreeSize(caps: u32) usize {
    return espz_heap_caps_get_free_size(caps);
}

pub fn capsGetTotalSize(caps: u32) usize {
    return espz_heap_caps_get_total_size(caps);
}

pub fn capsGetMinimumFreeSize(caps: u32) usize {
    return espz_heap_caps_get_minimum_free_size(caps);
}

pub fn capsMalloc(size: usize, caps: u32) ?[*]u8 {
    return espz_heap_caps_malloc(size, caps);
}

pub fn capsFree(ptr: ?[*]u8) void {
    espz_heap_caps_free(@ptrCast(ptr));
}
