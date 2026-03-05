# heap

Sdkconfig binding and runtime API for the ESP-IDF `heap` component.

## ESP-IDF component

Maps to [`heap`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/system/mem_alloc.html).

## Module boundary

Provides sdkconfig bindings for heap memory management: poisoning modes, tracing, task tracking, allocation-failure behavior, and flash placement.

Also exposes a **runtime API** via `root.zig`:

### Heap stats
- `freeHeapSize()` — returns current free heap bytes.
- `minimumFreeHeapSize()` — returns minimum free heap watermark since boot.
- `freeInternalHeapSize()` — returns free internal (non-PSRAM) heap bytes.

### Raw allocation
- `capsMalloc(size, caps)` — raw `heap_caps_malloc` wrapper.
- `capsFree(ptr)` — raw `heap_caps_free` wrapper.

### Capability flags (`Caps`)
Type-safe wrappers around ESP-IDF `MALLOC_CAP_*` constants. Values are chip-dependent and obtained at runtime via C shims.

- `Caps.dma`, `Caps.spiram`, `Caps.internal`, `Caps.default`, `Caps.exec`, `Caps.@"8bit"`, `Caps.@"32bit"`, `Caps.iram_8bit`, `Caps.retention`, `Caps.rtc`
- `Caps.combine(a, b)` — bitwise OR of two capability sets.
- `Caps.defaultPsram()` — `spiram | 8bit` (common PSRAM allocation pattern).
- `Caps.defaultInternal()` — `internal | 8bit` (common internal allocation pattern).

### `std.mem.Allocator` interface (`HeapCapsAllocator`)
A `std.mem.Allocator` backed by `heap_caps_malloc` / `heap_caps_free`, parameterised by `Caps`.

```zig
const heap = @import("heap");

// DMA-capable allocator
var dma = heap.heapCapsAllocator(heap.Caps.dma);
const dma_alloc = dma.allocator();
const buf = try dma_alloc.alloc(u8, 1024);
defer dma_alloc.free(buf);

// PSRAM allocator
var psram = heap.heapCapsAllocator(heap.Caps.defaultPsram());
const psram_alloc = psram.allocator();

// Default allocator (MALLOC_CAP_DEFAULT)
var default = heap.heapCapsAllocator(heap.Caps.default);
const default_alloc = default.allocator();
```

The module is registered with `zig_root` so firmware can `@import("heap")`.

## Dependencies

- ESP-IDF `heap` component (via `idf_requires`).
