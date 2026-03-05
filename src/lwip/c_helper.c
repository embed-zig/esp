#include <stddef.h>
#include <stdint.h>

#include "lwip/sockets.h"

int32_t espz_lwip_socket(int32_t domain, int32_t type, int32_t protocol)
{
    return (int32_t)lwip_socket(domain, type, protocol);
}

int32_t espz_lwip_close(int32_t fd)
{
    return (int32_t)lwip_close(fd);
}

int32_t espz_lwip_connect(int32_t fd, const struct sockaddr *addr, uint32_t addrlen)
{
    return (int32_t)lwip_connect(fd, addr, (socklen_t)addrlen);
}

int32_t espz_lwip_send(int32_t fd, const void *buf, uint32_t len, int32_t flags)
{
    return (int32_t)lwip_send(fd, buf, (size_t)len, flags);
}

int32_t espz_lwip_recv(int32_t fd, void *buf, uint32_t len, int32_t flags)
{
    return (int32_t)lwip_recv(fd, buf, (size_t)len, flags);
}

int32_t espz_lwip_sendto(int32_t fd, const void *buf, uint32_t len, int32_t flags,
                          const struct sockaddr *to, uint32_t tolen)
{
    return (int32_t)lwip_sendto(fd, buf, (size_t)len, flags, to, (socklen_t)tolen);
}

int32_t espz_lwip_recvfrom(int32_t fd, void *buf, uint32_t len, int32_t flags,
                            struct sockaddr *from, uint32_t *fromlen)
{
    socklen_t sl = (socklen_t)*fromlen;
    int32_t n = (int32_t)lwip_recvfrom(fd, buf, (size_t)len, flags, from, &sl);
    *fromlen = (uint32_t)sl;
    return n;
}

int32_t espz_lwip_bind(int32_t fd, const struct sockaddr *addr, uint32_t addrlen)
{
    return (int32_t)lwip_bind(fd, addr, (socklen_t)addrlen);
}

int32_t espz_lwip_listen(int32_t fd, int32_t backlog)
{
    return (int32_t)lwip_listen(fd, backlog);
}

int32_t espz_lwip_accept(int32_t fd, struct sockaddr *addr, uint32_t *addrlen)
{
    socklen_t sl = (socklen_t)*addrlen;
    int32_t client = (int32_t)lwip_accept(fd, addr, &sl);
    *addrlen = (uint32_t)sl;
    return client;
}

int32_t espz_lwip_setsockopt(int32_t fd, int32_t level, int32_t optname,
                              const void *optval, uint32_t optlen)
{
    return (int32_t)lwip_setsockopt(fd, level, optname, optval, (socklen_t)optlen);
}

int32_t espz_lwip_getsockname(int32_t fd, struct sockaddr *addr, uint32_t *addrlen)
{
    socklen_t sl = (socklen_t)*addrlen;
    int32_t ret = (int32_t)lwip_getsockname(fd, addr, &sl);
    *addrlen = (uint32_t)sl;
    return ret;
}

int32_t espz_lwip_fcntl(int32_t fd, int32_t cmd, int32_t val)
{
    return (int32_t)lwip_fcntl(fd, cmd, val);
}
