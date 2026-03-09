const hal_hci = @import("embed").hal.hci;

const VHci = @import("../component/bt/vhci.zig").VHci;
const Queue = @import("../component/freertos/queue.zig").Queue;

extern fn vTaskDelay(ticks: u32) void;
const port_tick_period_ms: i32 = 10;

const max_packet_size = 512;
const queue_depth = 8;

const PacketEntry = extern struct {
    len: u16 = 0,
    data: [max_packet_size]u8 = undefined,
};

const RxQueue = Queue(PacketEntry);

/// Callback routing pointer — the only global state.
/// Required because VHCI callbacks are bare C function pointers
/// without a user-context parameter.
var active_driver: ?*Driver = null;

const rom_printf = struct {
    extern fn esp_rom_printf(fmt: [*:0]const u8, ...) c_int;
}.esp_rom_printf;

fn onReadable(data: [*]u8, len: u16) callconv(.c) c_int {
    const drv = active_driver orelse return -1;
    if (len > max_packet_size) return -1;

    // Debug: log HCI event type for connection debugging
    if (len >= 1) {
        const indicator = data[0];
        if (indicator == 0x04 and len >= 2) {
            // HCI Event packet: log event code
            _ = rom_printf("[hci-rx] event=0x%02x len=%d\n", data[1], len);
        } else if (indicator == 0x02) {
            _ = rom_printf("[hci-rx] acl len=%d\n", len);
        }
    }

    var entry: PacketEntry = .{ .len = len };
    @memcpy(entry.data[0..len], data[0..len]);
    drv.rx_queue.send(&entry, 0) catch return -1;
    return 0;
}

fn onWritable() callconv(.c) void {}

const vhci_callbacks = VHci.HciCallbacks{
    .on_writable = &onWritable,
    .on_readable = &onReadable,
};

pub const Driver = struct {
    rx_queue: RxQueue = .{ .handle = null },
    registered: bool = false,

    pub fn read(self: *Driver, buf: []u8) hal_hci.Error!usize {
        self.ensureRegistered();
        const entry = self.rx_queue.receive(0) catch return error.WouldBlock;
        const n = @min(entry.len, @as(u16, @intCast(buf.len)));
        @memcpy(buf[0..n], entry.data[0..n]);
        return n;
    }

    pub fn write(self: *Driver, buf: []const u8) hal_hci.Error!usize {
        self.ensureRegistered();
        if (buf.len == 0 or buf.len > 0xFFFF) return error.HciError;
        // Debug: log HCI command being sent
        if (buf.len >= 4 and buf[0] == 0x01) {
            const opcode = @as(u16, buf[1]) | (@as(u16, buf[2]) << 8);
            _ = rom_printf("[hci-tx] cmd opcode=0x%04x len=%d\n", opcode, buf.len);
        }
        return switch (VHci.tryWrite(buf.ptr, @intCast(buf.len))) {
            .ok => buf.len,
            .would_block => error.WouldBlock,
            .invalid_length => error.HciError,
        };
    }

    pub fn poll(self: *Driver, flags: hal_hci.PollFlags, timeout_ms: i32) hal_hci.PollFlags {
        self.ensureRegistered();
        if (flags.readable and self.rx_queue.waiting() == 0 and timeout_ms > 0) {
            const ticks: u32 = @intCast(@max(1, @divTrunc(timeout_ms, port_tick_period_ms)));
            vTaskDelay(ticks);
        }
        return .{
            .readable = flags.readable and self.rx_queue.waiting() > 0,
            .writable = flags.writable and VHci.canWrite(),
        };
    }

    fn ensureRegistered(self: *Driver) void {
        if (!self.registered) {
            self.rx_queue = RxQueue.init(queue_depth) catch return;
            active_driver = self;
            VHci.registerCallbacks(&vhci_callbacks) catch {};
            self.registered = true;
        }
    }
};
