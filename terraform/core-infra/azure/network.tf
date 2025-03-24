data "azurerm_virtual_network" "plural" {
  name = var.network_name
  resource_group_name = var.project
}

data "azurerm_subnet" "pg" {
  name = var.pg_subnet_name
  virtual_network_name = var.network_name
  resource_group_name = var.project
}

resource "plural_service_context" "pg" {
  name = "plrl/subnets/pg"
  configuration = jsonencode({
    region       = var.region
    network_name = var.network_name
    network_id   = data.azurerm_virtual_network.plural.id
    subnet_name  = var.pg_subnet_name
    subnet_id    = data.azurerm_subnet.pg.id
  })
}
