data "google_container_cluster" "mgmt" {
  name = var.cluster_name
  location = var.region
}

data "google_compute_network" "network" {
  name = data.google_container_cluster.mgmt.network
}

data "google_compute_subnetwork" "subnetwork" {
  name = data.google_container_cluster.mgmt.subnetwork
}

resource "plural_service_context" "mgmt" {
    name = "plrl/clusters/mgmt"
    configuration = jsonencode({
        region       = var.region
        cluster_name = var.cluster_name
        network      = data.google_container_cluster.mgmt.network
        subnetwork   = data.google_container_cluster.mgmt.subnetwork
        cidr         = data.google_compute_subnetwork.subnetwork.ip_cidr_range
    })
}