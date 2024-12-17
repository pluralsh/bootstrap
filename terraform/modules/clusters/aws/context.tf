resource "plural_service_context" "mgmt" {
    name = "plrl/clusters/${var.cluster_name}"
    configuration = {
        cluster_name    = var.cluster_name
        vpc_id          = module.vpc.vpc_id
        subnet_ids      = concat(module.vpc.public_subnets, module.vpc.private_subnets)
        private_subnets = module.vpc.private_subnets
        public_subnets  = module.vpc.public_subnets
        vpc_cidr        = var.vpc_cidr
    }
}