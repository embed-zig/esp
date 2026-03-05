pub const Handle = u32;

pub const PartitionHandle = ?*anyopaque;

pub const AppState = enum(u32) {
    new = 0,
    pending_verify = 1,
    valid = 2,
    invalid = 3,
    aborted = 4,
    undefined = 5,
};

extern fn espz_ota_get_next_update_partition(from: PartitionHandle) PartitionHandle;
extern fn espz_ota_get_running_partition() PartitionHandle;
extern fn espz_ota_begin(partition: PartitionHandle, image_size: usize, out_handle: *Handle) i32;
extern fn espz_ota_write(handle: Handle, data: [*]const u8, size: usize) i32;
extern fn espz_ota_end(handle: Handle) i32;
extern fn espz_ota_abort(handle: Handle) i32;
extern fn espz_ota_set_boot_partition(partition: PartitionHandle) i32;
extern fn espz_ota_get_state_partition(partition: PartitionHandle, out_state: *u32) i32;
extern fn espz_ota_mark_valid() i32;
extern fn espz_ota_mark_invalid_rollback() i32;

pub const OTA_SIZE_UNKNOWN: usize = 0xffffffff;

pub const Error = error{
    NoPartition,
    BeginFailed,
    WriteFailed,
    EndFailed,
    AbortFailed,
    SetBootFailed,
    ConfirmFailed,
    RollbackFailed,
    StateFailed,
};

pub fn getNextUpdatePartition() Error!PartitionHandle {
    const p = espz_ota_get_next_update_partition(null);
    if (p == null) return error.NoPartition;
    return p;
}

pub fn getRunningPartition() Error!PartitionHandle {
    const p = espz_ota_get_running_partition();
    if (p == null) return error.NoPartition;
    return p;
}

pub fn begin(partition: PartitionHandle, image_size: u32) Error!Handle {
    var handle: Handle = 0;
    const size: usize = if (image_size == 0) OTA_SIZE_UNKNOWN else @intCast(image_size);
    if (espz_ota_begin(partition, size, &handle) != 0) return error.BeginFailed;
    return handle;
}

pub fn write(handle: Handle, data: []const u8) Error!void {
    if (espz_ota_write(handle, data.ptr, data.len) != 0) return error.WriteFailed;
}

pub fn end(handle: Handle) Error!void {
    if (espz_ota_end(handle) != 0) return error.EndFailed;
}

pub fn abort(handle: Handle) void {
    _ = espz_ota_abort(handle);
}

pub fn setBootPartition(partition: PartitionHandle) Error!void {
    if (espz_ota_set_boot_partition(partition) != 0) return error.SetBootFailed;
}

pub fn getPartitionState(partition: PartitionHandle) Error!AppState {
    var state: u32 = 5;
    if (espz_ota_get_state_partition(partition, &state) != 0) return error.StateFailed;
    return @enumFromInt(state);
}

pub fn markValid() Error!void {
    if (espz_ota_mark_valid() != 0) return error.ConfirmFailed;
}

pub fn markInvalidAndRollback() Error!void {
    if (espz_ota_mark_invalid_rollback() != 0) return error.RollbackFailed;
}
