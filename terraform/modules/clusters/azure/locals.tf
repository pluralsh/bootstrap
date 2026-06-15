locals {
  identity  = jsondecode(data.plural_service_context.identity.configuration)
  network   = jsondecode(data.plural_service_context.network.configuration)
  # Empty next_kubernetes_version means in sync with kubernetes_version (safe before scaffolds passes both).
  next_kubernetes_version = var.next_kubernetes_version != "" ? var.next_kubernetes_version : var.kubernetes_version
  upgrading = var.kubernetes_version != local.next_kubernetes_version
  # AKS upgrades control plane and node pools in separate applies; see clouds/azure/aks.tf.
  node_orchestrator_version = local.upgrading ? var.kubernetes_version : local.next_kubernetes_version
}
