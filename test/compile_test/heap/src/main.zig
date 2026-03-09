const esp = @import("esp");
const heap = esp.component.heap;

comptime {
    _ = heap.freeHeapSize;
    _ = heap.minimumFreeHeapSize;
    _ = heap.freeInternalHeapSize;
    _ = heap.capsMalloc;
    _ = heap.capsFree;
}

export fn zig_esp_main() callconv(.c) void {}
