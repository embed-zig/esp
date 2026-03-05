# freertos

Sdkconfig binding and runtime API for the ESP-IDF `freertos` component.

## ESP-IDF component

Maps to [`freertos`](https://docs.espressif.com/projects/esp-idf/en/stable/esp32s3/api-reference/system/freertos_idf.html).

## Module boundary

Provides sdkconfig bindings for FreeRTOS scheduler configuration: tick rate, core count (SMP/unicore), stack sizes, timer service, stack overflow detection, and task debugging options.

Also exposes a **runtime API**:

### Task management (`task.zig`)

- `create(task_fn, ctx, config)` — single task creation API:
  - core pinning (`core_id` / `no_affinity`)
  - caller-provided stack (`config.stack`)
  - stack ownership follows restricted pinned path semantics (task-side cleanup)
- `delete(handle)` — delete a task handle.
- `delay(ticks)` — delay current task (`vTaskDelay`).
- `msToTicks(ms, tick_rate_hz)` — convert milliseconds to tick count with floor semantics.
- capability constants helpers for stack allocation policy: `mallocCapSpiram`, `mallocCapInternal`, `mallocCap8Bit`.
- convenience caps helpers: `defaultPsramCaps`, `defaultInternalCaps`.
- `TickType` — tick counter type alias (`u32`).

### Queue (`queue.zig`)

- `Queue(T)` — generic typed queue: `init(depth)`, `deinit()`, `send(item, timeout)`, `receive(timeout)`, `waiting()`.
- `QueueSet` — queue set for multiplexing: `init(slot_count)`, `deinit()`, `addMember(handle)`, `removeMember(handle)`, `select(timeout)`.

### Synchronization primitives (`sync.zig`)

- `Mutex` — FreeRTOS mutex: `init()`, `deinit()`, `lock()`, `unlock()`.
- `Semaphore` — counting/binary semaphore: `initCounting(max, initial)`, `initBinary(initial_available)`, `deinit()`, `take(ticks)`, `give()`.

The module is registered with `zig_root` so firmware can `@import("freertos")`.

## Dependencies

- ESP-IDF `freertos` component (via `idf_requires`).
