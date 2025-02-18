locals {
  config = jsondecode(plural_service_context.mgmt.configuration)
}

output "region" {
  value = local.config.region
}

output "cluster_name" {
  value = local.config.cluster_name
}

output "vpc_id" {
  value = local.config.vpc_id
}

output "subnet_ids" {
  value = local.config.subnet_ids
}

output "vpc_cidr" {
  value = local.config.vpc_cidr
}
