const std = @import("std");
const runtime = @import("embed").runtime;

const posix = @import("../component/newlib/fs.zig");
const heap_alloc = @import("../component/heap/allocator.zig");
const FsError = runtime.fs.Error;
const OpenMode = runtime.fs.OpenMode;
const File = runtime.fs.File;

pub const Fs = struct {
    const FileCtx = struct {
        fd: i32,
    };

    pub fn open(_: *@This(), path: []const u8, mode: OpenMode) ?File {
        var path_buf: [256:0]u8 = undefined;
        if (path.len >= path_buf.len) return null;
        @memcpy(path_buf[0..path.len], path);
        path_buf[path.len] = 0;
        const cpath: [*:0]const u8 = &path_buf;

        const flags: i32 = switch (mode) {
            .read => posix.O_RDONLY,
            .write => posix.O_WRONLY | posix.O_CREAT | posix.O_TRUNC,
            .read_write => posix.O_RDWR | posix.O_CREAT,
        };

        const fd = posix.openFile(cpath, flags) catch return null;

        const ctx = heap_alloc.default.create(FileCtx) catch {
            posix.closeFile(fd);
            return null;
        };
        ctx.* = .{ .fd = fd };

        return File{
            .ctx = @ptrCast(ctx),
            .readFn = switch (mode) {
                .write => null,
                else => &readFn,
            },
            .writeFn = switch (mode) {
                .read => null,
                else => &writeFn,
            },
            .closeFn = &closeFn,
            .size = posix.fileSize(fd) catch 0,
        };
    }

    fn readFn(ctx_ptr: *anyopaque, buf: []u8) FsError!usize {
        const ctx: *FileCtx = @ptrCast(@alignCast(ctx_ptr));
        return posix.readFile(ctx.fd, buf) catch return FsError.IoError;
    }

    fn writeFn(ctx_ptr: *anyopaque, buf: []const u8) FsError!usize {
        const ctx: *FileCtx = @ptrCast(@alignCast(ctx_ptr));
        return posix.writeFile(ctx.fd, buf) catch return FsError.IoError;
    }

    fn closeFn(ctx_ptr: *anyopaque) void {
        const ctx: *FileCtx = @ptrCast(@alignCast(ctx_ptr));
        posix.closeFile(ctx.fd);
        heap_alloc.default.destroy(ctx);
    }

    pub const DirEntry = struct {
        name_buf: [256]u8,
        name_len: usize,
        is_dir: bool,

        pub fn name(self: *const DirEntry) []const u8 {
            return self.name_buf[0..self.name_len];
        }
    };

    pub fn readDir(_: *@This(), path: []const u8, buf: []DirEntry) ?usize {
        var path_buf: [256:0]u8 = undefined;
        if (path.len >= path_buf.len) return null;
        @memcpy(path_buf[0..path.len], path);
        path_buf[path.len] = 0;
        const cpath: [*:0]const u8 = &path_buf;

        const dir = posix.openDirectory(cpath) catch return null;
        defer posix.closeDirectory(dir);

        var count: usize = 0;
        while (count < buf.len) {
            const ent = posix.readDirectory(dir) orelse break;
            buf[count] = .{
                .name_buf = ent.name,
                .name_len = ent.name_len,
                .is_dir = ent.d_type == posix.DT_DIR,
            };
            count += 1;
        }
        return count;
    }
};
