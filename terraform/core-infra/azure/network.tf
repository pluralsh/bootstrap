data "azurerm_resource_group" "default" {
  name = var.resource_group_name
}

data "azurerm_private_dns_zone" "postgres" {
  name                = var.postgres_dns_zone
  resource_group_name = data.azurerm_resource_group.default.name
}

resource "azurerm_virtual_network" "dev" {
  name                = "dev"
  resource_group_name = data.azurerm_resource_group.default.name
  location            = var.region
  address_space       = var.network_cidrs
}

resource "azurerm_subnet" "dev_sn" {
  name                                           = "dev-sn"
  resource_group_name                            = data.azurerm_resource_group.default.name
  virtual_network_name                           = azurerm_virtual_network.dev.name
  address_prefixes                               = var.subnet_cidrs
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "dev_pg" {
  name                 = "dev-pg"
  resource_group_name  = data.azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.dev.name
  address_prefixes     = var.postgres_cidrs
  service_endpoints = ["Microsoft.Storage"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "dev_pg" {
  name                  = "dev.postgres.com"
  resource_group_name   = data.azurerm_resource_group.default.name
  private_dns_zone_name = data.azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.dev.id
}

resource "plural_service_context" "dev" {
  name = "plrl/network/dev"
  configuration = jsonencode({
    location       = azurerm_virtual_network.dev.location
    network_name   = azurerm_virtual_network.dev.name
    network_id     = azurerm_virtual_network.dev.id
    sn_subnet_name = azurerm_subnet.dev_sn.name
    sn_subnet_id   = azurerm_subnet.dev_sn.id
    pg_subnet_name = azurerm_subnet.dev_pg.name
    pg_subnet_id   = azurerm_subnet.dev_pg.id
    dns_zone_name  = data.azurerm_private_dns_zone.postgres.name
    dns_zone_id    = data.azurerm_private_dns_zone.postgres.id
  })
}

resource "azurerm_virtual_network" "prod" {
  name                = "prod"
  resource_group_name = data.azurerm_resource_group.default.name
  location            = var.region
  address_space       = var.network_cidrs
}

resource "azurerm_subnet" "prod_sn" {
  name                                           = "prod-sn"
  resource_group_name                            = data.azurerm_resource_group.default.name
  virtual_network_name                           = azurerm_virtual_network.prod.name
  address_prefixes                               = var.subnet_cidrs
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "prod_pg" {
  name                 = "prod-pg"
  resource_group_name  = data.azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.prod.name
  address_prefixes     = var.postgres_cidrs
  service_endpoints = ["Microsoft.Storage"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "prod_pg" {
  name                  = "prod.postgres.com"
  resource_group_name   = data.azurerm_resource_group.default.name
  private_dns_zone_name = data.azurerm_private_dns_zone.postgres.name
  virtual_network_id    = azurerm_virtual_network.prod.id
}

resource "plural_service_context" "prod" {
  name = "plrl/network/prod"
  configuration = jsonencode({
    location       = azurerm_virtual_network.prod.location
    network_name   = azurerm_virtual_network.prod.name
    network_id     = azurerm_virtual_network.prod.id
    sn_subnet_name = azurerm_subnet.prod_sn.name
    sn_subnet_id   = azurerm_subnet.prod_sn.id
    pg_subnet_name = azurerm_subnet.prod_pg.name
    pg_subnet_id   = azurerm_subnet.prod_pg.id
    dns_zone_name  = data.azurerm_private_dns_zone.postgres.name
    dns_zone_id    = data.azurerm_private_dns_zone.postgres.id
  })
}
