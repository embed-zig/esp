const std = @import("std");
const freertos = @import("../component/freertos/task.zig");
const runtime = @import("embed").runtime;

const SpawnConfig = runtime.thread.SpawnConfig;
const TaskFn = runtime.thread.types.TaskFn;

const ThreadState = struct {
    task: TaskFn,
    ctx: ?*anyopaque,
    allocator: std.mem.Allocator,
    done: std.atomic.Value(bool),
    detached: std.atomic.Value(bool),
    freed: std.atomic.Value(bool),
};

pub const Thread = struct {
    const Self = @This();

    handle: freertos.TaskHandle = null,
    state: ?*ThreadState = null,
    stack: ?[]u8 = null,
    allocator: std.mem.Allocator = undefined,

    const rom_printf = struct {
        extern fn esp_rom_printf(fmt: [*:0]const u8, ...) c_int;
    }.esp_rom_printf;

    pub fn spawn(
        config: SpawnConfig,
        task: TaskFn,
        ctx: ?*anyopaque,
    ) anyerror!Self {
        const alloc = config.allocator orelse return error.MissingAllocator;

        _ = rom_printf("[thread:%s] spawn: stack_size=%d\n", config.name, @as(c_int, @intCast(config.stack_size)));

        const state = alloc.create(ThreadState) catch |e| {
            _ = rom_printf("[thread:%s] alloc.create(ThreadState) FAILED: %s\n", config.name, @errorName(e).ptr);
            return e;
        };
        errdefer alloc.destroy(state);

        const stack = alloc.alloc(u8, config.stack_size) catch |e| {
            _ = rom_printf("[thread:%s] alloc.alloc(stack, %d) FAILED: %s\n", config.name, @as(c_int, @intCast(config.stack_size)), @errorName(e).ptr);
            return e;
        };
        errdefer alloc.free(stack);

        _ = rom_printf("[thread:%s] alloc OK, creating freertos task\n", config.name);

        state.* = .{
            .task = task,
            .ctx = ctx,
            .allocator = alloc,
            .done = std.atomic.Value(bool).init(false),
            .detached = std.atomic.Value(bool).init(false),
            .freed = std.atomic.Value(bool).init(false),
        };

        const core_id: freertos.CoreId = if (config.core_id) |cid|
            @intCast(cid)
        else
            freertos.no_affinity;

        const handle = freertos.create(taskEntry, state, .{
            .stack = .{ .ptr = stack.ptr, .len = stack.len },
            .priority = @as(u32, config.priority),
            .name = config.name,
            .core_id = core_id,
        }) catch |e| {
            _ = rom_printf("[thread:%s] freertos.create FAILED: %s\n", config.name, @errorName(e).ptr);
            return e;
        };

        return .{
            .handle = handle,
            .state = state,
            .stack = stack,
            .allocator = alloc,
        };
    }

    pub fn join(self: *Self) void {
        const state = self.state orelse return;
        while (!state.done.load(.acquire)) {
            freertos.delay(1);
        }
        freeResources(self);
    }

    pub fn detach(self: *Self) void {
        const state = self.state orelse return;
        state.detached.store(true, .release);
        if (state.done.load(.acquire)) {
            freeResources(self);
        } else {
            self.state = null;
            self.handle = null;
            self.stack = null;
        }
    }

    fn freeResources(self: *Self) void {
        if (self.state) |state| {
            if (!state.freed.swap(true, .acq_rel)) {
                self.allocator.destroy(state);
            }
        }
        if (self.stack) |stack| {
            self.allocator.free(stack);
        }
        self.state = null;
        self.handle = null;
        self.stack = null;
    }

    fn taskEntry(raw: ?*anyopaque) callconv(.c) void {
        const state: *ThreadState = @ptrCast(@alignCast(raw orelse {
            freertos.delete(null);
            return;
        }));

        state.task(state.ctx);
        state.done.store(true, .release);

        if (state.detached.load(.acquire)) {
            if (!state.freed.swap(true, .acq_rel)) {
                state.allocator.destroy(state);
            }
        }

        freertos.delete(null);
    }
};
