locals {
  identity  = jsondecode(data.plural_service_context.identity.configuration)
  network   = jsondecode(data.plural_service_context.network.configuration)
  upgrading = var.kubernetes_version != var.next_kubernetes_version
  # AKS upgrades control plane and node pools in separate applies; see clouds/azure/aks.tf.
  node_orchestrator_version = local.upgrading ? var.kubernetes_version : var.next_kubernetes_version
}
