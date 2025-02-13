output "plural_service_context" {
    value = {
        vpc_id          = plural_service_context.mgmt.configuration["vpc_id"]
        subnet_ids      = plural_service_context.mgmt.configuration["subnet_ids"]
        private_subnets = plural_service_context.mgmt.configuration["private_subnets"]
        public_subnets  = plural_service_context.mgmt.configuration["public_subnets"]
        vpc_cidr        = plural_service_context.mgmt.configuration["vpc_cidr"]
    }
}
