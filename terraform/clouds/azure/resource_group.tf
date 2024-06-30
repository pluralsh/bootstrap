resource "random_id" "prefix" {
  byte_length = 8
}

resource "azurerm_resource_group" "main" {
  count = var.create_resource_group ? 1 : 0

  location = var.location
  name     = coalesce(var.resource_group_name, "${random_id.prefix.hex}-rg")
}

data "azurerm_resource_group" "main" {
  count = var.create_resource_group ? 0 : 1
  name = var.resource_group_name
}