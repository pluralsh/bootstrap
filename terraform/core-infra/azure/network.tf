data "azurerm_resource_group" "default" {
  name = var.resource_group_name
}

data "azurerm_private_dns_zone" "postgres" {
  name                = var.postgres_dns_zone
  resource_group_name = data.azurerm_resource_group.default.name
}

data "azurerm_private_dns_zone" "mysql" {
  name                = var.mysql_dns_zone
  resource_group_name = data.azurerm_resource_group.default.name
}

data "azurerm_virtual_network" "plural" {
  name                = var.network_name
  resource_group_name = data.azurerm_resource_group.default.name
}

data "azurerm_subnet" "plural_sn" {
  name                 = "${var.network_name}-sn"
  resource_group_name  = data.azurerm_resource_group.default.name
  virtual_network_name = data.azurerm_virtual_network.plural.name
}

data "azurerm_subnet" "plural_pg" {
  name                 = "${var.network_name}-pg"
  resource_group_name  = data.azurerm_resource_group.default.name
  virtual_network_name = data.azurerm_virtual_network.plural.name
}

resource "plural_service_context" "plural" {
  name = "plrl/network/plural"
  configuration = jsonencode({
    location       = data.azurerm_virtual_network.plural.location
    network_name   = data.azurerm_virtual_network.plural.name
    network_id     = data.azurerm_virtual_network.plural.id
    sn_subnet_name = data.azurerm_subnet.plural_sn.name
    sn_subnet_id   = data.azurerm_subnet.plural_sn.id
    pg_subnet_name = data.azurerm_subnet.plural_pg.name
    pg_subnet_id   = data.azurerm_subnet.plural_pg.id
    dns_zone_name  = data.azurerm_private_dns_zone.postgres.name
    dns_zone_id    = data.azurerm_private_dns_zone.postgres.id
  })
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

resource "azurerm_subnet" "dev_mysql" {
  name                 = "dev-mysql"
  resource_group_name  = data.azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.dev.name
  address_prefixes     = var.mysql_cidrs
  service_endpoints = ["Microsoft.Storage"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
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

resource "azurerm_private_dns_zone_virtual_network_link" "dev_mysql" {
  name                  = "dev.mysql.com"
  resource_group_name   = data.azurerm_resource_group.default.name
  private_dns_zone_name = data.azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.dev.id
}

resource "plural_service_context" "dev" {
  name = "plrl/network/dev"
  configuration = jsonencode({
    location          = azurerm_virtual_network.dev.location
    network_name      = azurerm_virtual_network.dev.name
    network_id        = azurerm_virtual_network.dev.id
    sn_subnet_name    = azurerm_subnet.dev_sn.name
    sn_subnet_id      = azurerm_subnet.dev_sn.id
    pg_subnet_name    = azurerm_subnet.dev_pg.name
    pg_subnet_id      = azurerm_subnet.dev_pg.id
    pg_dns_zone_name  = data.azurerm_private_dns_zone.postgres.name
    pg_dns_zone_id    = data.azurerm_private_dns_zone.postgres.id
    mysql_subnet_name = azurerm_subnet.dev_mysql.name
    mysql_subnet_id   = azurerm_subnet.dev_mysql.id
    mysql_dns_zone_name  = data.azurerm_private_dns_zone.mysql.name
    mysql_dns_zone_id    = data.azurerm_private_dns_zone.mysql.id
  {{ if .AppDomain }}
    ingress_dns_zone = "dev.{{ .AppDomain }}"
  {{ end}}

    # Kept for backwards compatibility. Use fields with pg_ prefix instead.
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

resource "azurerm_subnet" "prod_mysql" {
  name                 = "prod-mysql"
  resource_group_name  = data.azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.prod.name
  address_prefixes     = var.mysql_cidrs
  service_endpoints = ["Microsoft.Storage"]

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
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

resource "azurerm_private_dns_zone_virtual_network_link" "prod_mysql" {
  name                  = "prod.mysql.com"
  resource_group_name   = data.azurerm_resource_group.default.name
  private_dns_zone_name = data.azurerm_private_dns_zone.mysql.name
  virtual_network_id    = azurerm_virtual_network.prod.id
}

resource "plural_service_context" "prod" {
  name = "plrl/network/prod"
  configuration = jsonencode({
    location          = azurerm_virtual_network.prod.location
    network_name      = azurerm_virtual_network.prod.name
    network_id        = azurerm_virtual_network.prod.id
    sn_subnet_name    = azurerm_subnet.prod_sn.name
    sn_subnet_id      = azurerm_subnet.prod_sn.id
    pg_subnet_name    = azurerm_subnet.prod_pg.name
    pg_subnet_id      = azurerm_subnet.prod_pg.id
    pg_dns_zone_name  = data.azurerm_private_dns_zone.postgres.name
    pg_dns_zone_id    = data.azurerm_private_dns_zone.postgres.id
    mysql_subnet_name = azurerm_subnet.prod_mysql.name
    mysql_subnet_id   = azurerm_subnet.prod_mysql.id
    mysql_dns_zone_name  = data.azurerm_private_dns_zone.mysql.name
    mysql_dns_zone_id    = data.azurerm_private_dns_zone.mysql.id
    {{ if .AppDomain }}
    ingress_dns_zone = "{{ .AppDomain }}"
    {{ end}}
    # Kept for backwards compatibility. Use fields with pg_ prefix instead.
    dns_zone_name  = data.azurerm_private_dns_zone.postgres.name
    dns_zone_id    = data.azurerm_private_dns_zone.postgres.id
  })
}
