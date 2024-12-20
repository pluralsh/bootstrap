module "aks" {
  source = "Azure/aks/azurerm"
  version = "9.2.0"

  kubernetes_version   = var.kubernetes_version
  cluster_name         = var.cluster_name
  resource_group_name  = local.resource_group.name
  prefix               = var.cluster_name
  os_disk_size_gb      = 60
  sku_tier             = "Standard"
  rbac_aad             = false
  vnet_subnet_id       = azurerm_subnet.network.id
  node_pools           = {for name, pool in var.node_pools : name => merge(pool, {name = name, vnet_subnet_id = azurerm_subnet.network.id})}
  
  ebpf_data_plane     = "cilium"
  network_plugin_mode = "overlay"
  network_plugin      = "azure"

  role_based_access_control_enabled = true

  workload_identity_enabled = var.workload_identity_enabled
  oidc_issuer_enabled       = var.workload_identity_enabled
}