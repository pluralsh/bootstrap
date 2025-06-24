data "azurerm_dns_zone" "prod" {
  name                = "{{ .AppDomain }}"
  resource_group_name = "{{ .ResourceGroupName }}"
}

resource "azurerm_dns_zone" "dev" {
  name                = "dev.{{ .AppDomain }}"
  resource_group_name = "{{ .ResourceGroupName }}"
}

resource "azurerm_dns_ns_record" "dev_ns" {
  name                = "dev"
  zone_name           = data.azurerm_dns_zone.prod.name
  resource_group_name = data.azurerm_dns_zone.prod.resource_group_name
  ttl                 = 30
  records             = azurerm_dns_zone.dev.name_servers
}
