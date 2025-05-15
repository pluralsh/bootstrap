
locals {
  resource_group = {
    name     = var.create_resource_group ? azurerm_resource_group.main[0].name : var.resource_group_name
    location = var.location
  }
  rg = var.create_resource_group ? azurerm_resource_group.main[0] : data.azurerm_resource_group.main[0]
  db_url = format("postgresql://console:%s@%s:5432/console", random_password.password.result, try(azurerm_postgresql_flexible_server.postgres[0].fqdn, ""))
}