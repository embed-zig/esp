const Handle = ?*anyopaque;

pub const Error = error{
    CreateFailed,
    QueueFull,
    QueueEmpty,
    InvalidHandle,
    SetAddFailed,
    SetRemoveFailed,
};

extern fn espz_queue_create(length: u32, item_size: u32) Handle;
extern fn espz_queue_send(q: Handle, item: ?*const anyopaque, ticks: u32) i32;
extern fn espz_queue_receive(q: Handle, buffer: ?*anyopaque, ticks: u32) i32;
extern fn espz_queue_messages_waiting(q: Handle) u32;
extern fn espz_queue_delete(q: Handle) void;
extern fn espz_queue_create_set(length: u32) Handle;
extern fn espz_queue_add_to_set(member: Handle, set: Handle) i32;
extern fn espz_queue_remove_from_set(member: Handle, set: Handle) i32;
extern fn espz_queue_select_from_set(set: Handle, ticks: u32) Handle;

const pd_true: i32 = 1;

pub fn Queue(comptime T: type) type {
    return struct {
        const Self = @This();

        handle: Handle,

        pub fn init(depth: u32) Error!Self {
            const h = espz_queue_create(depth, @sizeOf(T));
            if (h == null) return error.CreateFailed;
            return .{ .handle = h };
        }

        pub fn deinit(self: *Self) void {
            espz_queue_delete(self.handle);
            self.handle = null;
        }

        pub fn send(self: *Self, item: *const T, timeout_ticks: u32) Error!void {
            if (espz_queue_send(self.handle, @ptrCast(item), timeout_ticks) != 1) {
                return error.QueueFull;
            }
        }

        pub fn receive(self: *Self, timeout_ticks: u32) Error!T {
            var item: T = undefined;
            if (espz_queue_receive(self.handle, @ptrCast(&item), timeout_ticks) != 1) {
                return error.QueueEmpty;
            }
            return item;
        }

        pub fn waiting(self: *const Self) u32 {
            return espz_queue_messages_waiting(self.handle);
        }

        pub fn rawHandle(self: *const Self) Handle {
            return self.handle;
        }
    };
}

pub const QueueSet = struct {
    handle: Handle,

    pub fn init(slot_count: u32) Error!QueueSet {
        const h = espz_queue_create_set(slot_count);
        if (h == null) return error.CreateFailed;
        return .{ .handle = h };
    }

    pub fn deinit(self: *QueueSet) void {
        espz_queue_delete(self.handle);
        self.handle = null;
    }

    pub fn addMember(self: *QueueSet, member: Handle) Error!void {
        if (member == null) return error.InvalidHandle;
        if (espz_queue_add_to_set(member, self.handle) != pd_true) return error.SetAddFailed;
    }

    pub fn removeMember(self: *QueueSet, member: Handle) Error!void {
        if (member == null) return error.InvalidHandle;
        if (espz_queue_remove_from_set(member, self.handle) != pd_true) return error.SetRemoveFailed;
    }

    /// Returns the selected member handle, or null on timeout.
    pub fn select(self: *QueueSet, timeout_ticks: u32) Handle {
        return espz_queue_select_from_set(self.handle, timeout_ticks);
    }

    pub fn rawHandle(self: *const QueueSet) Handle {
        return self.handle;
    }
};
