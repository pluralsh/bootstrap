resource "plural_service_context" "mgmt" {
    name = "plrl/clusters/${var.cluster}"

    configuration = jsonencode({
        region       = var.region
        cluster_name = var.cluster
        network      = module.gcp-network.network_name
        subnetwork   = module.gcp-network.subnets_names[0]
        cidr         = var.subnet_cidr
    })
}