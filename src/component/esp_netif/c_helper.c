#include <stddef.h>
#include <stdint.h>

#include "esp_netif.h"

esp_netif_t *espz_netif_get_handle_from_ifkey(const char *if_key)
{
    return esp_netif_get_handle_from_ifkey(if_key);
}

int32_t espz_netif_get_ip_info(esp_netif_t *netif, esp_netif_ip_info_t *ip_info)
{
    return (int32_t)esp_netif_get_ip_info(netif, ip_info);
}

int32_t espz_netif_set_ip_info(esp_netif_t *netif, const esp_netif_ip_info_t *ip_info)
{
    return (int32_t)esp_netif_set_ip_info(netif, ip_info);
}

int32_t espz_netif_get_dns_info(esp_netif_t *netif, uint32_t dns_type, esp_netif_dns_info_t *dns)
{
    return (int32_t)esp_netif_get_dns_info(netif, (esp_netif_dns_type_t)dns_type, dns);
}

int32_t espz_netif_set_dns_info(esp_netif_t *netif, uint32_t dns_type, const esp_netif_dns_info_t *dns)
{
    return (int32_t)esp_netif_set_dns_info(netif, (esp_netif_dns_type_t)dns_type, dns);
}

int32_t espz_netif_is_up(esp_netif_t *netif)
{
    return esp_netif_is_netif_up(netif) ? 1 : 0;
}

void espz_netif_set_default(esp_netif_t *netif)
{
    esp_netif_set_default_netif(netif);
}

int32_t espz_netif_get_impl_name(esp_netif_t *netif, char *name)
{
    return (int32_t)esp_netif_get_netif_impl_name(netif, name);
}

int32_t espz_netif_get_nr_of_ifs(void)
{
    return (int32_t)esp_netif_get_nr_of_ifs();
}

esp_netif_t *espz_netif_next(esp_netif_t *netif)
{
    return esp_netif_next(netif);
}

int32_t espz_netif_dhcpc_get_status(esp_netif_t *netif, uint32_t *status)
{
    esp_netif_dhcp_status_t s;
    esp_err_t err = esp_netif_dhcpc_get_status(netif, &s);
    if (err != ESP_OK) return (int32_t)err;
    *status = (uint32_t)s;
    return 0;
}
