locals {
  db_name = "${var.db_name_prefix}-${random_string.random.result}"
}

resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
  special     = false
}

resource "random_string" "random" {
  length  = 8
  upper   = false
  special = false
}

resource "azurerm_private_dns_zone" "postgres" {
  count = var.create_db ? 1 : 0

  name                = var.postgres_dns_zone
  resource_group_name = local.resource_group.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  count = var.create_db ? 1 : 0

  name                  = var.network_link_name
  private_dns_zone_name = azurerm_private_dns_zone.postgres[0].name
  virtual_network_id    = azurerm_virtual_network.network.id
  resource_group_name   = local.resource_group.name
}

resource "azurerm_postgresql_flexible_server" "postgres" {
  count = var.create_db ? 1 : 0
  name                   = local.db_name
  resource_group_name    = local.resource_group.name
  location               = local.resource_group.location
  version                = "13"
  delegated_subnet_id    = azurerm_subnet.postgres.id
  private_dns_zone_id    = azurerm_private_dns_zone.postgres[0].id
  administrator_login    = "console"
  administrator_password = random_password.password.result
  public_network_access_enabled = false

  storage_mb = var.postgres_disk
  sku_name   = var.postgres_sku

  high_availability {
    mode = "ZoneRedundant"
  }

  lifecycle {
    ignore_changes = [ zone, high_availability.0.standby_availability_zone ]
  }

  depends_on = [ azurerm_subnet.postgres ]
}

resource "azurerm_postgresql_flexible_server_database" "console" {
  count     = var.create_db ? 1 : 0
  name      = "console"
  server_id = azurerm_postgresql_flexible_server.postgres[0].id
  collation = "en_US.utf8"
  charset   = "utf8"
}