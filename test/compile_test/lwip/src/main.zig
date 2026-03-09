const esp = @import("esp");
const lwip = esp.component.lwip;

comptime {
    _ = lwip.socket;
    _ = lwip.socket.SockaddrIn;
    _ = lwip.socket.socket;
    _ = lwip.socket.close;
    _ = lwip.socket.connect;
    _ = lwip.socket.send;
    _ = lwip.socket.recv;
    _ = lwip.socket.bind;
    _ = lwip.socket.listen;
    _ = lwip.socket.accept;
    _ = lwip.socket.htons;
}

export fn zig_esp_main() callconv(.c) void {}
