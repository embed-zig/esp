extern fn espz_spiffs_register(label: [*:0]const u8, base_path: [*:0]const u8, max_files: i32, format_if_failed: i32) i32;
extern fn espz_spiffs_unregister(label: [*:0]const u8) i32;
extern fn espz_spiffs_info(label: [*:0]const u8, total: *usize, used: *usize) i32;

pub const Error = error{
    MountFailed,
    UnmountFailed,
    InfoFailed,
};

pub const Info = struct {
    total: usize,
    used: usize,
};

pub fn mount(label: [:0]const u8, base_path: [:0]const u8, max_files: u8, format_if_failed: bool) Error!void {
    if (espz_spiffs_register(label.ptr, base_path.ptr, @intCast(max_files), @intFromBool(format_if_failed)) != 0)
        return error.MountFailed;
}

pub fn unmount(label: [:0]const u8) void {
    _ = espz_spiffs_unregister(label.ptr);
}

pub fn info(label: [:0]const u8) Error!Info {
    var total: usize = 0;
    var used: usize = 0;
    if (espz_spiffs_info(label.ptr, &total, &used) != 0)
        return error.InfoFailed;
    return .{ .total = total, .used = used };
}
