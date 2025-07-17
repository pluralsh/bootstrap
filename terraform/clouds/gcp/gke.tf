locals {
  node_pool_add = {
    (local.active_node_group) = {
      cluster_version = var.kubernetes_version,
    },
    (local.drain_node_group) = {
      cluster_version = var.next_kubernetes_version,
    }
  }

  full_node_pools = {
    for k, v in var.node_pools : k => merge(v, try(lookup(local.node_pool_add, k), {}))
    if k != local.drain_node_group || local.upgrading == true
  }

  node_pool_taints_add = {
    for ng in [local.active_node_group] : ng => local.upgrading ?
      [{ key = "platform.plural.sh/pending", value = "upgrade", effect = "NO_SCHEDULE" }] : []
  }

  full_node_pools_taints = {
    for k, v in var.node_pools_taints : k => concat(v, try(lookup(local.node_pool_taints_add, k), []))
    if k != local.drain_node_group || local.upgrading == true
  }
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "~> 33.0"

  kubernetes_version       = var.next_kubernetes_version
  project_id               = var.project_id
  name                     = var.cluster_name
  regional                 = true
  grant_registry_access    = true
  region                   = var.region
  network                  = module.gcp-network.network_name
  subnetwork               = module.gcp-network.subnets_names[0]
  ip_range_pods            = var.ip_range_pods_name
  ip_range_services        = var.ip_range_services_name
  create_service_account   = true
  deletion_protection      = var.deletion_protection
  node_pools               = [for k, v in local.full_node_pools : merge(v, { name = k })]
  node_pools_taints        = local.full_node_pools_taints
  node_pools_labels        = var.node_pools_labels
  node_pools_tags          = var.node_pools_tags
  remove_default_node_pool = true

  datapath_provider = "ADVANCED_DATAPATH"

  release_channel = "UNSPECIFIED"

  depends_on = [
    google_project_service.gcr,
    google_project_service.container,
    google_project_service.iam,
    google_project_service.storage,
    google_project_service.dns,
  ]
}
