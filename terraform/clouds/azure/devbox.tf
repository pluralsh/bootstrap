# Plural devboxes: node auto-provisioning (AKS's managed Karpenter) for Agent Substrate's gVisor workers, the storage
# account Substrate keeps actor snapshots in, and the Workload Identity identities that reach it. Devbox homes are Azure
# managed disks. The services in bootstrap/devbox add the devbox NodePool and AKSNodeClass, Substrate and the
# DevboxRunner on top. Needs workload_identity_enabled.

variable "devbox_enabled" {
  type    = bool
  default = true
}

locals {
  devbox = var.devbox_enabled ? 1 : 0
  # Storage account names are 3-24 lowercase alphanumerics and globally unique.
  devbox_account_prefix = substr(replace(lower("ate${var.cluster_name}"), "/[^a-z0-9]/", ""), 0, 16)
  # The objectstore-azure-blob plugin runs next to atelet (node) and ate-api-server (control), each as its own Entra
  # identity federated to that pod's ServiceAccount.
  devbox_identities = var.devbox_enabled ? {
    node    = "atelet"
    control = "ate-api-server"
  } : {}
}

data "azurerm_client_config" "devbox" {}

# Devbox nodes come from node auto-provisioning, which launches each one in the zone its worker's home disk is in. The
# cluster autoscaler can't: a pool spanning zones is one scale set that picks the zone itself. NAP runs beside the
# autoscaled blue and green pools only with this subscription feature; the devbox NodePool's taint and label keep the
# two from scaling for the same pods.
resource "azapi_resource_action" "devbox_nap_feature" {
  count                  = local.devbox
  type                   = "Microsoft.Features/providers/features@2021-07-01"
  resource_id            = "/subscriptions/${data.azurerm_client_config.devbox.subscription_id}/providers/Microsoft.Features/providers/Microsoft.ContainerService/features/AllowClusterAutoscalerAndNAP"
  action                 = "register"
  method                 = "POST"
  response_export_values = ["properties.state"]
}

# Registering takes a few minutes and azapi 1.x, which the AKS module pins, can't poll it. If AKS still rejects NAP
# below, apply again.
resource "time_sleep" "devbox_nap_feature" {
  count           = local.devbox
  create_duration = azapi_resource_action.devbox_nap_feature[0].output.properties.state == "Registered" ? "0s" : "10m"
}

# picks up the feature in the resource provider, as `az provider register` does
resource "azapi_resource_action" "devbox_nap_provider" {
  count       = local.devbox
  type        = "Microsoft.Resources/providers@2021-04-01"
  resource_id = "/subscriptions/${data.azurerm_client_config.devbox.subscription_id}/providers/Microsoft.ContainerService"
  action      = "register"
  method      = "POST"

  depends_on = [time_sleep.devbox_nap_feature]
}

# No default NodePools: they're untainted, so NAP would add nodes for the same pending pods as the cluster autoscaler.
# The only NodePool is the devbox one in services/devbox.
resource "azapi_update_resource" "devbox_nap" {
  count       = local.devbox
  type        = "Microsoft.ContainerService/managedClusters@2025-10-01"
  resource_id = module.aks.aks_id

  body = {
    properties = {
      nodeProvisioningProfile = {
        mode             = "Auto"
        defaultNodePools = "None"
      }
    }
  }

  timeouts {
    create = "40m"
    update = "40m"
  }

  # NAP joins nodes to the cluster's subnet as the cluster identity, which needs to read and join it
  depends_on = [azapi_resource_action.devbox_nap_provider, azurerm_role_assignment.aks-network-identity-ssi]
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
