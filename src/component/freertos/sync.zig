const std = @import("std");

const Handle = ?*anyopaque;

extern fn espz_semaphore_create_mutex() Handle;
extern fn espz_semaphore_create_binary() Handle;
extern fn espz_semaphore_create_counting(max_count: u32, initial_count: u32) Handle;
extern fn espz_semaphore_take(handle: Handle, ticks: u32) i32;
extern fn espz_semaphore_give(handle: Handle) i32;
extern fn espz_semaphore_delete(handle: Handle) void;

pub const Error = error{CreateFailed};

pub const max_delay: u32 = std.math.maxInt(u32);

const pd_true: i32 = 1;

pub const Mutex = struct {
    handle: Handle,

    pub fn init() Error!Mutex {
        const h = espz_semaphore_create_mutex() orelse return error.CreateFailed;
        return .{ .handle = h };
    }

    pub fn deinit(self: *Mutex) void {
        if (self.handle) |h| {
            espz_semaphore_delete(h);
            self.handle = null;
        }
    }

    pub fn lock(self: *Mutex) void {
        while (espz_semaphore_take(self.handle, max_delay) != pd_true) {}
    }

    pub fn unlock(self: *Mutex) void {
        _ = espz_semaphore_give(self.handle);
    }
};

pub const Semaphore = struct {
    handle: Handle,

    pub fn initCounting(max_count: u32, initial_count: u32) Error!Semaphore {
        const h = espz_semaphore_create_counting(max_count, initial_count) orelse return error.CreateFailed;
        return .{ .handle = h };
    }

    pub fn initBinary(initial_available: bool) Error!Semaphore {
        const h = espz_semaphore_create_binary() orelse return error.CreateFailed;
        var sem = Semaphore{ .handle = h };
        if (initial_available) _ = sem.give();
        return sem;
    }

    pub fn deinit(self: *Semaphore) void {
        if (self.handle) |h| {
            espz_semaphore_delete(h);
            self.handle = null;
        }
    }

    pub fn take(self: *Semaphore, ticks: u32) bool {
        return espz_semaphore_take(self.handle, ticks) == pd_true;
    }

    pub fn give(self: *Semaphore) bool {
        return espz_semaphore_give(self.handle) == pd_true;
    }

    pub fn rawHandle(self: *const Semaphore) ?*anyopaque {
        return self.handle;
    }
};
