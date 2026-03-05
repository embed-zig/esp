const std = @import("std");

pub const O_RDONLY: i32 = 0;
pub const O_WRONLY: i32 = 1;
pub const O_RDWR: i32 = 2;
pub const O_CREAT: i32 = 0x200;
pub const O_TRUNC: i32 = 0x400;

pub const SEEK_SET: i32 = 0;
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

extern fn open(path: [*:0]const u8, flags: i32, ...) i32;
extern fn close(fd: i32) i32;
extern fn read(fd: i32, buf: [*]u8, count: usize) isize;
extern fn write(fd: i32, buf: [*]const u8, count: usize) isize;
extern fn lseek(fd: i32, offset: i32, whence: i32) i32;
extern fn fstat(fd: i32, buf: *Stat) i32;
extern fn unlink(path: [*:0]const u8) i32;
extern fn rename(old: [*:0]const u8, new: [*:0]const u8) i32;

pub const Error = error{
    OpenFailed,
    ReadFailed,
    WriteFailed,
    SeekFailed,
    StatFailed,
    CloseFailed,
    DeleteFailed,
    RenameFailed,
};

pub fn openFile(path: [*:0]const u8, flags: i32) Error!i32 {
    const fd = open(path, flags, @as(i32, 0o666));
    if (fd < 0) return error.OpenFailed;
    return fd;
}

pub fn closeFile(fd: i32) void {
    _ = close(fd);
}

pub fn readFile(fd: i32, buf: []u8) Error!usize {
    const n = read(fd, buf.ptr, buf.len);
    if (n < 0) return error.ReadFailed;
    return @intCast(n);
}

pub fn writeFile(fd: i32, buf: []const u8) Error!usize {
    const n = write(fd, buf.ptr, buf.len);
    if (n < 0) return error.WriteFailed;
    return @intCast(n);
}

pub fn fileSize(fd: i32) Error!u32 {
    var st = Stat{};
    if (fstat(fd, &st) != 0) return error.StatFailed;
    if (st.st_size < 0) return error.StatFailed;
    return @intCast(st.st_size);
}

pub fn seekEnd(fd: i32) i32 {
    return lseek(fd, 0, SEEK_END);
}

pub fn seekBegin(fd: i32) i32 {
    return lseek(fd, 0, SEEK_SET);
}

pub fn deleteFile(path: [*:0]const u8) Error!void {
    if (unlink(path) != 0) return error.DeleteFailed;
}

pub fn renameFile(old_path: [*:0]const u8, new_path: [*:0]const u8) Error!void {
    if (rename(old_path, new_path) != 0) return error.RenameFailed;
}
