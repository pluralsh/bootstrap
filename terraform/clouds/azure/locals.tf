
locals {
  network_name = var.network_name == "" ? "${var.cluster_name}-network" : var.network_name
  resource_group = {
    name     = var.create_resource_group ? azurerm_resource_group.main[0].name : var.resource_group_name
    location = var.location
  }
  rg = var.create_resource_group ? azurerm_resource_group.main[0] : data.azurerm_resource_group.main[0]
  db_url = format("postgresql://console:%s@%s:5432/console", random_password.password.result, try(azurerm_postgresql_flexible_server.postgres[0].fqdn, ""))

  upgrading = var.kubernetes_version != var.next_kubernetes_version
  split_vsn = [ for i in split(".", var.kubernetes_version): tonumber(i) ]
  vsn_even = ((tonumber(local.split_vsn[0]) * 100 + tonumber(local.split_vsn[1])) % 2) == 0
  active_node_group = local.vsn_even ? "blue" : "green"
  drain_node_group = local.vsn_even ? "green" : "blue"
}