pub const Error = error{
    EspFail,
    InvalidArgument,
    NotFound,
    BufferTooSmall,
    StorageFull,
    SchemaMismatch,
};

const code_ok: i32 = 0;
const code_invalid_arg: i32 = 1;
const code_not_found: i32 = 2;
const code_buffer_too_small: i32 = 3;
const code_storage_full: i32 = 4;
const code_schema_mismatch: i32 = 5;

pub const Handle = u32;

pub const Namespace = struct {
    handle: Handle,

    pub fn open(name: []const u8) Error!Namespace {
        var out: Handle = 0;
        try check(espz_nvs_open_rw(name.ptr, name.len, &out));
        return .{ .handle = out };
    }

    pub fn close(self: *Namespace) void {
        espz_nvs_close(self.handle);
        self.handle = 0;
    }

    pub fn getU32(self: *Namespace, key: []const u8) Error!u32 {
        var out: u32 = 0;
        try check(espz_nvs_get_u32(self.handle, key.ptr, key.len, &out));
        return out;
    }

    pub fn setU32(self: *Namespace, key: []const u8, value: u32) Error!void {
        try check(espz_nvs_set_u32(self.handle, key.ptr, key.len, value));
    }

    pub fn getI32(self: *Namespace, key: []const u8) Error!i32 {
        var out: i32 = 0;
        try check(espz_nvs_get_i32(self.handle, key.ptr, key.len, &out));
        return out;
    }

    pub fn setI32(self: *Namespace, key: []const u8, value: i32) Error!void {
        try check(espz_nvs_set_i32(self.handle, key.ptr, key.len, value));
    }

    pub fn getString(self: *Namespace, key: []const u8, out: []u8) Error![]const u8 {
        var out_len: usize = out.len;
        try check(espz_nvs_get_blob(self.handle, key.ptr, key.len, out.ptr, out.len, &out_len));
        return out[0..out_len];
    }

    pub fn setString(self: *Namespace, key: []const u8, value: []const u8) Error!void {
        try check(espz_nvs_set_blob(self.handle, key.ptr, key.len, value.ptr, value.len));
    }

    pub fn erase(self: *Namespace, key: []const u8) Error!void {
        try check(espz_nvs_erase_key(self.handle, key.ptr, key.len));
    }

    pub fn eraseAll(self: *Namespace) Error!void {
        try check(espz_nvs_erase_all(self.handle));
    }

    pub fn commit(self: *Namespace) Error!void {
        try check(espz_nvs_commit(self.handle));
    }
};

extern fn nvs_flash_init() i32;
extern fn nvs_flash_deinit() i32;
extern fn nvs_flash_erase() i32;

extern fn espz_nvs_open_rw(ns_ptr: [*]const u8, ns_len: usize, out_handle: *Handle) i32;
extern fn espz_nvs_close(handle: Handle) void;
extern fn espz_nvs_get_u32(handle: Handle, key_ptr: [*]const u8, key_len: usize, out: *u32) i32;
extern fn espz_nvs_set_u32(handle: Handle, key_ptr: [*]const u8, key_len: usize, value: u32) i32;
extern fn espz_nvs_get_i32(handle: Handle, key_ptr: [*]const u8, key_len: usize, out: *i32) i32;
extern fn espz_nvs_set_i32(handle: Handle, key_ptr: [*]const u8, key_len: usize, value: i32) i32;
extern fn espz_nvs_get_blob(
    handle: Handle,
    key_ptr: [*]const u8,
    key_len: usize,
    out_buf: [*]u8,
    out_cap: usize,
    out_len: *usize,
) i32;
extern fn espz_nvs_set_blob(
    handle: Handle,
    key_ptr: [*]const u8,
    key_len: usize,
    data_ptr: [*]const u8,
    data_len: usize,
) i32;
extern fn espz_nvs_erase_key(handle: Handle, key_ptr: [*]const u8, key_len: usize) i32;
extern fn espz_nvs_erase_all(handle: Handle) i32;
extern fn espz_nvs_commit(handle: Handle) i32;

pub fn init() Error!void {
    try check(nvs_flash_init());
}

pub fn deinit() Error!void {
    try check(nvs_flash_deinit());
}

pub fn erase() Error!void {
    try check(nvs_flash_erase());
}

fn check(code: i32) Error!void {
    return switch (code) {
        code_ok => {},
        code_invalid_arg => error.InvalidArgument,
        code_not_found => error.NotFound,
        code_buffer_too_small => error.BufferTooSmall,
        code_storage_full => error.StorageFull,
        code_schema_mismatch => error.SchemaMismatch,
        else => error.EspFail,
    };
}
