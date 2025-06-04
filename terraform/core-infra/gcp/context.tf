data "google_container_cluster" "mgmt" {
  name     = var.cluster_name
  location = var.region
}

locals {
  short_network_name = basename(data.google_container_cluster.mgmt.network)
  short_subnetwork_name = basename(data.google_container_cluster.mgmt.subnetwork)
}

data "google_compute_network" "network" {
  name = local.short_network_name
}

data "google_compute_subnetwork" "subnetwork" {
  name = local.short_subnetwork_name
}

resource "plural_service_context" "mgmt" {
  name = "plrl/clusters/mgmt"
  configuration = jsonencode({
    region       = var.region
    cluster_name = var.cluster_name
    network      = data.google_container_cluster.mgmt.network
    subnetwork   = data.google_container_cluster.mgmt.subnetwork
    cidr         = data.google_compute_subnetwork.subnetwork.ip_cidr_range
    project_id   = var.project
  })
}

resource "plural_service_context" "plural-vpc" {
  name = "plrl/vpc/plural"

  configuration = jsonencode({
    network           = data.google_compute_network.network.name
    subnetwork        = data.google_container_cluster.mgmt.subnetwork
  })
}