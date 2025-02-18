locals {
  config = jsondecode(plural_service_context.mgmt.configuration)
}

output "plural_service_context" {
  value = {
    region       = local.config.region
    cluster_name = local.config.cluster_name
    vpc_id       = local.config.vpc_id
    subnet_ids   = local.config.subnet_ids
    vpc_cidr     = local.config.vpc_cidr
  }
}
