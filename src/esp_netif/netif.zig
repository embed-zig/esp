const std = @import("std");

pub const Handle = ?*anyopaque;

pub const IpInfo = extern struct {
    ip: u32 = 0,
    netmask: u32 = 0,
    gw: u32 = 0,
};

pub const DnsType = enum(u32) {
    main = 0,
    backup = 1,
    fallback = 2,
};

pub const DnsInfo = extern struct {
    ip: u32 = 0,
};

pub const Error = error{
    NetifFailed,
};

extern fn espz_netif_get_handle_from_ifkey(if_key: [*:0]const u8) Handle;
extern fn espz_netif_get_ip_info(netif: Handle, ip_info: *IpInfo) i32;
extern fn espz_netif_set_ip_info(netif: Handle, ip_info: *const IpInfo) i32;
extern fn espz_netif_get_dns_info(netif: Handle, dns_type: u32, dns: *DnsInfo) i32;
extern fn espz_netif_set_dns_info(netif: Handle, dns_type: u32, dns: *const DnsInfo) i32;
extern fn espz_netif_is_up(netif: Handle) i32;
extern fn espz_netif_set_default(netif: Handle) void;
extern fn espz_netif_get_impl_name(netif: Handle, name: [*]u8) i32;
extern fn espz_netif_get_nr_of_ifs() i32;
extern fn espz_netif_next(netif: Handle) Handle;
extern fn espz_netif_dhcpc_get_status(netif: Handle, status: *u32) i32;

pub fn getHandleFromIfKey(if_key: [*:0]const u8) Handle {
    return espz_netif_get_handle_from_ifkey(if_key);
}

pub fn getIpInfo(netif: Handle) Error!IpInfo {
    var info = IpInfo{};
    if (espz_netif_get_ip_info(netif, &info) != 0) return error.NetifFailed;
    return info;
}

pub fn setIpInfo(netif: Handle, info: *const IpInfo) Error!void {
    if (espz_netif_set_ip_info(netif, info) != 0) return error.NetifFailed;
}

pub fn getDnsInfo(netif: Handle, dns_type: DnsType) Error![4]u8 {
    var dns = DnsInfo{};
    if (espz_netif_get_dns_info(netif, @intFromEnum(dns_type), &dns) != 0) return error.NetifFailed;
    return ip4ToBytes(dns.ip);
}

pub fn setDnsInfo(netif: Handle, dns_type: DnsType, addr: [4]u8) Error!void {
    const dns = DnsInfo{ .ip = ip4FromBytes(addr) };
    if (espz_netif_set_dns_info(netif, @intFromEnum(dns_type), &dns) != 0) return error.NetifFailed;
}

pub fn isUp(netif: Handle) bool {
    return espz_netif_is_up(netif) != 0;
}

pub fn setDefaultNetif(netif: Handle) void {
    espz_netif_set_default(netif);
}

pub fn getImplName(netif: Handle) Error![16]u8 {
    var buf: [16]u8 = std.mem.zeroes([16]u8);
    if (espz_netif_get_impl_name(netif, &buf) != 0) return error.NetifFailed;
    return buf;
}

pub fn getNumberOfIfs() u32 {
    const n = espz_netif_get_nr_of_ifs();
    if (n < 0) return 0;
    return @intCast(n);
}

pub fn nextNetif(netif: Handle) Handle {
    return espz_netif_next(netif);
}

pub fn isDhcpClient(netif: Handle) Error!bool {
    var status: u32 = 0;
    if (espz_netif_dhcpc_get_status(netif, &status) != 0) return error.NetifFailed;
    return status == 1;
}

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
