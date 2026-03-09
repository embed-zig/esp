const std = @import("std");

pub const O_RDONLY: i32 = 0;
pub const O_WRONLY: i32 = 1;
pub const O_RDWR: i32 = 2;
pub const O_CREAT: i32 = 0x200;
pub const O_TRUNC: i32 = 0x400;

pub const SEEK_SET: i32 = 0;
pub const SEEK_CUR: i32 = 1;
pub const SEEK_END: i32 = 2;

pub const Stat = extern struct {
    st_dev: u32 = 0,
    st_ino: u32 = 0,
    st_mode: u32 = 0,
    st_nlink: u32 = 0,
    st_uid: u32 = 0,
    st_gid: u32 = 0,
    st_rdev: u32 = 0,
    st_size: i32 = 0,
    _pad: [32]u8 = std.mem.zeroes([32]u8),
};

extern fn espz_open(path: [*:0]const u8, flags: i32, mode: i32) i32;
extern fn espz_close(fd: i32) i32;
extern fn espz_read(fd: i32, buf: [*]u8, count: usize) i32;
extern fn espz_write(fd: i32, buf: [*]const u8, count: usize) i32;
extern fn espz_lseek(fd: i32, offset: i32, whence: i32) i32;
extern fn espz_unlink(path: [*:0]const u8) i32;
extern fn espz_rename(old: [*:0]const u8, new: [*:0]const u8) i32;

pub const DT_UNKNOWN: u8 = 0;
pub const DT_REG: u8 = 1;
pub const DT_DIR: u8 = 2;

extern fn espz_opendir(name: [*:0]const u8) ?*anyopaque;
extern fn espz_readdir(dirp: *anyopaque, name_out: [*]u8, name_buf_len: usize, type_out: *u8) i32;
extern fn espz_closedir(dirp: *anyopaque) i32;

pub const DirEntry = struct {
    name: [256]u8,
    name_len: usize,
    d_type: u8,

    pub fn nameSlice(self: *const DirEntry) []const u8 {
        return self.name[0..self.name_len];
    }
};

pub const Error = error{
    OpenFailed,
    ReadFailed,
    WriteFailed,
    SeekFailed,
    StatFailed,
    CloseFailed,
    DeleteFailed,
    RenameFailed,
    OpenDirFailed,
};

pub fn openFile(path: [*:0]const u8, flags: i32) Error!i32 {
    const fd = espz_open(path, flags, 0o666);
    if (fd < 0) return error.OpenFailed;
    return fd;
}

pub fn closeFile(fd: i32) void {
    _ = espz_close(fd);
}

pub fn readFile(fd: i32, buf: []u8) Error!usize {
    const n = espz_read(fd, buf.ptr, buf.len);
    if (n < 0) return error.ReadFailed;
    return @intCast(n);
}

pub fn writeFile(fd: i32, buf: []const u8) Error!usize {
    const n = espz_write(fd, buf.ptr, buf.len);
    if (n < 0) return error.WriteFailed;
    return @intCast(n);
}

pub fn fileSize(fd: i32) Error!u32 {
    const cur = espz_lseek(fd, 0, SEEK_CUR);
    if (cur < 0) return error.SeekFailed;
    const end = espz_lseek(fd, 0, SEEK_END);
    if (end < 0) return error.SeekFailed;
    _ = espz_lseek(fd, cur, SEEK_SET);
    return @intCast(end);
}

pub fn seekEnd(fd: i32) i32 {
    return espz_lseek(fd, 0, SEEK_END);
}

pub fn seekBegin(fd: i32) i32 {
    return espz_lseek(fd, 0, SEEK_SET);
}

pub fn deleteFile(path: [*:0]const u8) Error!void {
    if (espz_unlink(path) != 0) return error.DeleteFailed;
}

pub fn renameFile(old_path: [*:0]const u8, new_path: [*:0]const u8) Error!void {
    if (espz_rename(old_path, new_path) != 0) return error.RenameFailed;
}

pub fn openDirectory(path: [*:0]const u8) Error!*anyopaque {
    return espz_opendir(path) orelse return error.OpenDirFailed;
}

pub fn readDirectory(dir: *anyopaque) ?DirEntry {
    var entry: DirEntry = .{
        .name = std.mem.zeroes([256]u8),
        .name_len = 0,
        .d_type = DT_UNKNOWN,
    };
    const rc = espz_readdir(dir, &entry.name, entry.name.len, &entry.d_type);
    if (rc == 0) return null;
    entry.name_len = std.mem.indexOfScalar(u8, &entry.name, 0) orelse entry.name.len;
    return entry;
}

pub fn closeDirectory(dir: *anyopaque) void {
    _ = espz_closedir(dir);
}
