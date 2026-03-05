pub const Error = error{
    CreateFailed,
    BindFailed,
    ConnectFailed,
    SendFailed,
    RecvFailed,
    SetOptionFailed,
    Timeout,
    Closed,
    ListenFailed,
    AcceptFailed,
};

pub const AF_INET: i32 = 2;
pub const SOCK_STREAM: i32 = 1;
pub const SOCK_DGRAM: i32 = 2;
pub const IPPROTO_TCP: i32 = 6;
pub const IPPROTO_UDP: i32 = 17;
pub const SOL_SOCKET: i32 = 0xfff;
pub const SO_RCVTIMEO: i32 = 0x1006;
pub const SO_SNDTIMEO: i32 = 0x1005;
pub const TCP_NODELAY: i32 = 0x01;
pub const O_NONBLOCK: i32 = 1;
pub const F_GETFL: i32 = 3;
pub const F_SETFL: i32 = 4;
pub const MSG_DONTWAIT: i32 = 0x08;

pub const SockaddrIn = extern struct {
    sin_len: u8 = @sizeOf(SockaddrIn),
    sin_family: u8 = @intCast(AF_INET),
    sin_port: u16 = 0,
    sin_addr: u32 = 0,
    sin_zero: [8]u8 = .{0} ** 8,
};

pub const Timeval = extern struct {
    tv_sec: i32 = 0,
    tv_usec: i32 = 0,
};

extern fn espz_lwip_socket(domain: i32, sock_type: i32, protocol: i32) i32;
extern fn espz_lwip_close(fd: i32) i32;
extern fn espz_lwip_connect(fd: i32, addr: *const SockaddrIn, addrlen: u32) i32;
extern fn espz_lwip_send(fd: i32, buf: [*]const u8, len: u32, flags: i32) i32;
extern fn espz_lwip_recv(fd: i32, buf: [*]u8, len: u32, flags: i32) i32;
extern fn espz_lwip_sendto(fd: i32, buf: [*]const u8, len: u32, flags: i32, to: *const SockaddrIn, tolen: u32) i32;
extern fn espz_lwip_recvfrom(fd: i32, buf: [*]u8, len: u32, flags: i32, from: *SockaddrIn, fromlen: *u32) i32;
extern fn espz_lwip_bind(fd: i32, addr: *const SockaddrIn, addrlen: u32) i32;
extern fn espz_lwip_listen(fd: i32, backlog: i32) i32;
extern fn espz_lwip_accept(fd: i32, addr: *SockaddrIn, addrlen: *u32) i32;
extern fn espz_lwip_setsockopt(fd: i32, level: i32, optname: i32, optval: *const anyopaque, optlen: u32) i32;
extern fn espz_lwip_getsockname(fd: i32, addr: *SockaddrIn, addrlen: *u32) i32;
extern fn espz_lwip_fcntl(fd: i32, cmd: i32, val: i32) i32;

pub fn ip4ToBytes(addr: u32) [4]u8 {
    return .{
        @truncate(addr),
        @truncate(addr >> 8),
        @truncate(addr >> 16),
        @truncate(addr >> 24),
    };
}

pub fn ip4FromBytes(b: [4]u8) u32 {
    return @as(u32, b[0]) | (@as(u32, b[1]) << 8) | (@as(u32, b[2]) << 16) | (@as(u32, b[3]) << 24);
}

pub fn ipv4Addr(a: u8, b: u8, c: u8, d: u8) u32 {
    return ip4FromBytes(.{ a, b, c, d });
}

pub fn htons(v: u16) u16 {
    return @byteSwap(v);
}

pub fn ntohs(v: u16) u16 {
    return @byteSwap(v);
}

pub fn socket(sock_type: i32, protocol: i32) Error!i32 {
    const fd = espz_lwip_socket(AF_INET, sock_type, protocol);
    if (fd < 0) return error.CreateFailed;
    return fd;
}

pub fn close(fd: i32) void {
    _ = espz_lwip_close(fd);
}

pub fn connect(fd: i32, addr: [4]u8, port: u16) Error!void {
    var sa = SockaddrIn{
        .sin_port = htons(port),
        .sin_addr = ip4FromBytes(addr),
    };
    if (espz_lwip_connect(fd, &sa, @sizeOf(SockaddrIn)) != 0) return error.ConnectFailed;
}

pub fn send(fd: i32, data: []const u8) Error!usize {
    const n = espz_lwip_send(fd, data.ptr, @intCast(data.len), 0);
    if (n < 0) return error.SendFailed;
    return @intCast(n);
}

pub fn recv(fd: i32, buf: []u8) Error!usize {
    const n = espz_lwip_recv(fd, buf.ptr, @intCast(buf.len), 0);
    if (n < 0) return error.RecvFailed;
    return @intCast(n);
}

pub const RecvFromResult = struct {
    len: usize,
    addr: [4]u8,
    port: u16,
};

pub fn sendTo(fd: i32, addr: [4]u8, port: u16, data: []const u8) Error!usize {
    var sa = SockaddrIn{
        .sin_port = htons(port),
        .sin_addr = ip4FromBytes(addr),
    };
    const n = espz_lwip_sendto(fd, data.ptr, @intCast(data.len), 0, &sa, @sizeOf(SockaddrIn));
    if (n < 0) return error.SendFailed;
    return @intCast(n);
}

pub fn recvFrom(fd: i32, buf: []u8) Error!RecvFromResult {
    var src = SockaddrIn{};
    var src_len: u32 = @sizeOf(SockaddrIn);
    const n = espz_lwip_recvfrom(fd, buf.ptr, @intCast(buf.len), 0, &src, &src_len);
    if (n < 0) return error.RecvFailed;
    return .{
        .len = @intCast(n),
        .addr = ip4ToBytes(src.sin_addr),
        .port = ntohs(src.sin_port),
    };
}

pub fn bind(fd: i32, addr: [4]u8, port: u16) Error!void {
    var sa = SockaddrIn{
        .sin_port = htons(port),
        .sin_addr = ip4FromBytes(addr),
    };
    if (espz_lwip_bind(fd, &sa, @sizeOf(SockaddrIn)) != 0) return error.BindFailed;
}

pub fn getBoundPort(fd: i32) Error!u16 {
    var sa = SockaddrIn{};
    var sa_len: u32 = @sizeOf(SockaddrIn);
    if (espz_lwip_getsockname(fd, &sa, &sa_len) != 0) return error.BindFailed;
    return ntohs(sa.sin_port);
}

pub fn listen(fd: i32, backlog: i32) Error!void {
    if (espz_lwip_listen(fd, backlog) != 0) return error.ListenFailed;
}

pub fn accept(fd: i32) Error!i32 {
    var peer = SockaddrIn{};
    var peer_len: u32 = @sizeOf(SockaddrIn);
    const client = espz_lwip_accept(fd, &peer, &peer_len);
    if (client < 0) return error.AcceptFailed;
    return client;
}

pub fn setRecvTimeout(fd: i32, timeout_ms: u32) Error!void {
    var tv = Timeval{
        .tv_sec = @intCast(timeout_ms / 1000),
        .tv_usec = @intCast((timeout_ms % 1000) * 1000),
    };
    if (espz_lwip_setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, @ptrCast(&tv), @sizeOf(Timeval)) != 0)
        return error.SetOptionFailed;
}

pub fn setSendTimeout(fd: i32, timeout_ms: u32) Error!void {
    var tv = Timeval{
        .tv_sec = @intCast(timeout_ms / 1000),
        .tv_usec = @intCast((timeout_ms % 1000) * 1000),
    };
    if (espz_lwip_setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, @ptrCast(&tv), @sizeOf(Timeval)) != 0)
        return error.SetOptionFailed;
}

pub fn setTcpNoDelay(fd: i32, enabled: bool) Error!void {
    var v: i32 = if (enabled) 1 else 0;
    if (espz_lwip_setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, @ptrCast(&v), @sizeOf(i32)) != 0)
        return error.SetOptionFailed;
}

pub fn setNonBlocking(fd: i32, enabled: bool) Error!void {
    var flags = espz_lwip_fcntl(fd, F_GETFL, 0);
    if (flags < 0) return error.SetOptionFailed;
    if (enabled) {
        flags |= O_NONBLOCK;
    } else {
        flags &= ~O_NONBLOCK;
    }
    if (espz_lwip_fcntl(fd, F_SETFL, flags) < 0) return error.SetOptionFailed;
}
