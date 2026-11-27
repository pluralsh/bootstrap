# Plural devboxes: a node pool for Agent Substrate's gVisor workers, the storage account Substrate keeps actor
# snapshots and ZeroFS devbox homes in, and the Workload Identity identities that reach it. The services in
# bootstrap/devbox install Substrate and the DevboxRunner on top. Needs workload_identity_enabled.

variable "devbox_enabled" {
  type    = bool
  default = true
}

variable "devbox_vm_size" {
  type        = string
  default     = "Standard_D8s_v5"
  description = "one VM size, since gVisor snapshots need a single CPU model across the pool"
}

variable "devbox_max_nodes" {
  type    = number
  default = 5
}

variable "devbox_boot_disk_size" {
  type        = number
  default     = 250
  description = "size in GiB of the OS disk, which also holds /var/lib/ate"
}

locals {
  devbox = var.devbox_enabled ? 1 : 0
  # Storage account names are 3-24 lowercase alphanumerics and globally unique.
  devbox_account_prefix = substr(replace(lower("ate${var.cluster_name}"), "/[^a-z0-9]/", ""), 0, 16)
  # The objectstore-azure-blob plugin runs next to atelet (node) and ate-api-server (control), and the ZeroFS driver
  # keeps devbox homes in the same container, each as its own Entra identity federated to that pod's ServiceAccount.
  devbox_identities = var.devbox_enabled ? {
    node    = "atelet"
    control = "ate-api-server"
    zerofs  = "devbox-zerofs"
  } : {}
}

data "azurerm_client_config" "devbox" {}

resource "azurerm_kubernetes_cluster_node_pool" "devbox" {
  count                 = local.devbox
  name                  = "devbox"
  kubernetes_cluster_id = module.aks.aks_id
  vm_size               = var.devbox_vm_size
  orchestrator_version  = local.node_orchestrator_version
  os_sku                = "Ubuntu"
  os_disk_size_gb       = var.devbox_boot_disk_size
  os_disk_type          = "Managed"
  vnet_subnet_id        = azurerm_subnet.network.id

  enable_auto_scaling = true
  min_count           = 0
  max_count           = var.devbox_max_nodes
  node_count          = 0

  node_labels = {
    "plural.sh/devbox-pool" = "devbox"
  }

  # no plural.sh/devbox-disk startup taint here: AKS refuses to remove taints set on a node pool, and with
  # /var/lib/ate on the OS disk there's nothing for devbox-disk-prep to wait for
  node_taints = [
    "ate.dev/sandboxClass=gvisor:NoSchedule",
  ]

  upgrade_settings {
    max_surge = "1"
  }

  lifecycle {
    ignore_changes = [node_count]
  }
}

resource "random_string" "devbox" {
  count   = local.devbox
  length  = 8
  upper   = false
  special = false
}

resource "azurerm_storage_account" "devbox" {
  count                           = local.devbox
  name                            = "${local.devbox_account_prefix}${random_string.devbox[0].result}"
  resource_group_name             = local.resource_group.name
  location                        = local.resource_group.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "devbox" {
  count                 = local.devbox
  name                  = "snapshots"
  storage_account_name  = azurerm_storage_account.devbox[0].name
  container_access_type = "private"
}

resource "azurerm_user_assigned_identity" "devbox" {
  for_each            = local.devbox_identities
  name                = "${var.cluster_name}-${each.value}"
  resource_group_name = local.resource_group.name
  location            = local.resource_group.location
}

resource "azurerm_federated_identity_credential" "devbox" {
  for_each            = local.devbox_identities
  name                = "ate-system-${each.value}"
  resource_group_name = local.resource_group.name
  parent_id           = azurerm_user_assigned_identity.devbox[each.key].id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_issuer_url
  subject             = "system:serviceaccount:ate-system:${each.value}"
}

resource "azurerm_role_assignment" "devbox" {
  for_each             = local.devbox_identities
  scope                = azurerm_storage_account.devbox[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.devbox[each.key].principal_id
}

output "devbox_snapshot_location" {
  value = try("azblob://${azurerm_storage_container.devbox[0].name}/substrate/", "")
}

output "devbox_account_url" {
  value = try(trimsuffix(azurerm_storage_account.devbox[0].primary_blob_endpoint, "/"), "")
}

output "devbox_tenant_id" {
  value = data.azurerm_client_config.devbox.tenant_id
}

output "devbox_node_client_id" {
  value = try(azurerm_user_assigned_identity.devbox["node"].client_id, "")
}

output "devbox_control_client_id" {
  value = try(azurerm_user_assigned_identity.devbox["control"].client_id, "")
}

output "devbox_zerofs_client_id" {
  value = try(azurerm_user_assigned_identity.devbox["zerofs"].client_id, "")
}
