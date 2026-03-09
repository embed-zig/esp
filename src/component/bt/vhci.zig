const std = @import("std");

/// HCI transport binding over ESP-IDF VHCI.
///
/// This type intentionally exposes only transport-facing capabilities:
/// callback registration, writable check, and packet write attempt.
/// It does not expose controller lifecycle or host protocol APIs.
pub const VHci = struct {
    pub const Error = error{EspFail};

    /// Result of attempting to write an HCI packet.
    pub const WriteResult = enum(u8) {
        /// Packet was accepted by VHCI.
        ok,
        /// VHCI is temporarily not writable.
        would_block,
        /// Packet length is invalid for transport write.
        invalid_length,
    };

    /// Callback set for HCI transport events.
    pub const HciCallbacks = extern struct {
        /// Called when controller indicates host can try to write.
        on_writable: ?*const fn () callconv(.c) void,
        /// Called when controller pushes an HCI packet to host.
        on_readable: ?*const fn (data: [*]u8, len: u16) callconv(.c) c_int,
    };

    const NativeCallbacks = extern struct {
        notify_host_send_available: ?*const fn () callconv(.c) void,
        notify_host_recv: ?*const fn (data: [*]u8, len: u16) callconv(.c) c_int,
    };

    var native_callbacks: NativeCallbacks = .{
        .notify_host_send_available = null,
        .notify_host_recv = null,
    };

    extern fn esp_vhci_host_register_callback(callback: *const NativeCallbacks) i32;
    extern fn esp_vhci_host_check_send_available() bool;
    extern fn esp_vhci_host_send_packet(data: [*]u8, len: u16) void;

    /// Register readable/writable callbacks to VHCI.
    pub fn registerCallbacks(callbacks: *const HciCallbacks) Error!void {
        native_callbacks = .{
            .notify_host_send_available = callbacks.on_writable,
            .notify_host_recv = callbacks.on_readable,
        };
        if (esp_vhci_host_register_callback(&native_callbacks) != 0) return error.EspFail;
    }

    /// Check whether VHCI currently accepts host packets.
    pub fn canWrite() bool {
        return esp_vhci_host_check_send_available();
    }

    /// Try to send one HCI packet through VHCI.
    ///
    /// Returns:
    /// - `.ok` when packet is sent
    /// - `.would_block` when transport is not writable
    /// - `.invalid_length` when `len == 0`
    pub fn tryWrite(packet: [*]const u8, len: u16) WriteResult {
        const decision = classifyWrite(canWrite(), len);
        if (decision != .ok) {
            return decision;
        }

        esp_vhci_host_send_packet(@constCast(packet), len);
        return .ok;
    }

    /// Internal classifier for write preconditions.
    fn classifyWrite(send_available: bool, len: u16) WriteResult {
        if (len == 0) {
            return .invalid_length;
        }
        if (!send_available) {
            return .would_block;
        }
        return .ok;
    }
};

test "classifyWrite rejects zero-length packet" {
    try std.testing.expectEqual(VHci.WriteResult.invalid_length, VHci.classifyWrite(true, 0));
}

test "classifyWrite reports would_block when transport is not writable" {
    try std.testing.expectEqual(VHci.WriteResult.would_block, VHci.classifyWrite(false, 4));
}

test "classifyWrite accepts non-zero packet when writable" {
    try std.testing.expectEqual(VHci.WriteResult.ok, VHci.classifyWrite(true, 4));
}
