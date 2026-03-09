const std = @import("std");

extern fn vTaskDelay(ticks: u32) void;
extern fn vTaskDelete(task: ?*anyopaque) void;
extern fn espz_freertos_create_restricted_pinned(
    task_fn: TaskEntryFn,
    name: [*:0]const u8,
    stack_size_bytes: u32,
    stack_buffer: [*]u8,
    ctx: ?*anyopaque,
    priority: u32,
    out_handle: *TaskHandle,
    core_id: CoreId,
) i32;
extern fn espz_freertos_malloc_cap_spiram() u32;
extern fn espz_freertos_malloc_cap_internal() u32;
extern fn espz_freertos_malloc_cap_8bit() u32;

pub const TickType = u32;
pub const TaskHandle = ?*anyopaque;
pub const TaskEntryFn = *const fn (?*anyopaque) callconv(.c) void;
pub const CoreId = i32;
pub const no_affinity: CoreId = std.math.maxInt(CoreId);

pub const Stack = struct {
    ptr: [*]u8,
    len: usize,
};

pub const Error = error{
    CreateFailed,
    InvalidConfig,
};

pub const CreateConfig = struct {
    stack: Stack,
    priority: u32 = 5,
    name: [*:0]const u8 = "zig-task",
    core_id: CoreId = no_affinity,
};

/// Delay the calling task for the given number of ticks.
pub fn delay(ticks: u32) void {
    vTaskDelay(ticks);
}

pub fn delete(handle: TaskHandle) void {
    vTaskDelete(handle);
}

pub fn create(task_fn: TaskEntryFn, ctx: ?*anyopaque, config: CreateConfig) Error!TaskHandle {
    const stack_size_bytes = try stackSizeToU32(config.stack.len);

    var handle: TaskHandle = null;
    const rc = espz_freertos_create_restricted_pinned(
        task_fn,
        config.name,
        stack_size_bytes,
        config.stack.ptr,
        ctx,
        config.priority,
        &handle,
        config.core_id,
    );
    if (rc != 1 or handle == null) return error.CreateFailed;
    return handle;
}

pub fn msToTicks(milliseconds: u32, tick_rate_hz: u32) TickType {
    if (tick_rate_hz == 0) return 0;

    const numerator: u64 = @as(u64, milliseconds) * @as(u64, tick_rate_hz);
    return @intCast(numerator / 1000);
}

fn stackSizeToU32(stack_size_bytes: usize) Error!u32 {
    if (stack_size_bytes == 0) return error.InvalidConfig;
    if (stack_size_bytes > std.math.maxInt(u32)) return error.InvalidConfig;
    return @intCast(stack_size_bytes);
}

pub fn mallocCapSpiram() u32 {
    return espz_freertos_malloc_cap_spiram();
}

pub fn mallocCapInternal() u32 {
    return espz_freertos_malloc_cap_internal();
}

pub fn mallocCap8Bit() u32 {
    return espz_freertos_malloc_cap_8bit();
}

pub fn defaultPsramCaps() u32 {
    return mallocCapSpiram() | mallocCap8Bit();
}

pub fn defaultInternalCaps() u32 {
    return mallocCapInternal() | mallocCap8Bit();
}

test "msToTicks converts milliseconds with floor semantics" {
    try std.testing.expectEqual(@as(TickType, 10), msToTicks(100, 100));
    try std.testing.expectEqual(@as(TickType, 0), msToTicks(1, 100));
    try std.testing.expectEqual(@as(TickType, 0), msToTicks(100, 0));
}
