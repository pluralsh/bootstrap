resource "plural_service_context" "mgmt" {
    name = "plrl/clusters/${var.cluster}"

    configuration = jsonencode({
        region       = var.region
        cluster_name = var.cluster
        network      = local.vpc.network
        subnetwork   = local.vpc.subnetwork
        cidr         = var.subnet_cidr
    })
}