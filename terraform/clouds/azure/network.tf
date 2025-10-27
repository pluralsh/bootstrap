resource "azurerm_virtual_network" "network" {
  address_space       = var.network_cidrs
  location            = local.resource_group.location
  name                = local.network_name
  resource_group_name = local.resource_group.name
}

resource "azurerm_subnet" "network" {
  address_prefixes                               = var.subnet_cidrs
  name                                           = "${var.network_name}-sn"
  resource_group_name                            = local.resource_group.name
  virtual_network_name                           = azurerm_virtual_network.network.name
  enforce_private_link_endpoint_network_policies = true
}

resource "azurerm_subnet" "postgres" {
  name                 = "${var.network_name}-pg"
  resource_group_name  = local.resource_group.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = var.postgres_cidrs
  service_endpoints    = ["Microsoft.Storage"]
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