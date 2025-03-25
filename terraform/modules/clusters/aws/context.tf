resource "plural_service_context" "cluster" {
    name = "plrl/clusters/${var.cluster}"

    configuration = jsonencode({
        region          = var.region
        cluster_name    = var.cluster
        vpc_id          = local.vpc.vpc_id
        subnet_ids      = concat(local.vpc.private_subnets, local.vpc.public_subnets)
        private_subnets = local.vpc.private_subnets
        public_subnets  = local.vpc.public_subnets
        vpc_cidr        = var.vpc_cidr
    })
}