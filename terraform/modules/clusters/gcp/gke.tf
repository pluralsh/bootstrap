data "plural_service_context" "network" {
  name = "plrl/vpc/${var.tier}"
}

data "google_client_config" "current" {}

locals {
  project_id = data.google_client_config.current.project
  vpc = jsondecode(data.plural_service_context.network.configuration)
}

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "~> 33.0"

  kubernetes_version     = var.kubernetes_version
  project_id             = local.project_id
  name                   = var.cluster
  regional               = true
  grant_registry_access  = true
  region                 = var.region
  network                = local.vpc.network
  subnetwork             = local.vpc.subnetwork
  ip_range_pods          = local.vpc.ip_range_pods_name
  ip_range_services      = local.vpc.ip_range_services_name
  create_service_account = true
  deletion_protection    = false
  node_pools             = var.node_pools
  node_pools_taints      = var.node_pools_taints
  node_pools_labels      = var.node_pools_labels
  node_pools_tags        = var.node_pools_tags

  datapath_provider = "ADVANCED_DATAPATH"

  depends_on = [
    google_project_service.gcr,
    google_project_service.container,
    google_project_service.iam,
    google_project_service.storage,
    google_project_service.dns,
    # local.db_created,
  ]
}
