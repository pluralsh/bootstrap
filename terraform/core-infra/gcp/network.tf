data "google_project" "current" {}

locals {
  dev_subnet = format("%s-plural-dev", var.cluster_name)
  prod_subnet = format("%s-plural-prod", var.cluster_name)
}

module "network_dev" {
  source  = "terraform-google-modules/network/google"
  version = ">= 7.5"

  project_id = data.google_project.current.number
  network_name = format("%s-plural-dev", var.cluster_name)

  subnets = [
    {
      subnet_name   = local.dev_subnet
      subnet_ip     = var.subnet_cidr
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (local.dev_subnet) = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = var.pods_cidr
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = var.services_cidr
      },
    ]
  }
}

module "network_prod" {
  source  = "terraform-google-modules/network/google"
  version = ">= 7.5"

  project_id = data.google_project.current.number
  network_name = format("%s-plural-prod", var.cluster_name)

  subnets = [
    {
      subnet_name   = local.prod_subnet
      subnet_ip     = var.subnet_cidr
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (local.prod_subnet) = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = var.pods_cidr
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = var.services_cidr
      },
    ]
  }
}

resource "plural_service_context" "dev-vpc" {
  name = "plrl/vpc/dev"

  configuration = jsonencode({
    network           = module.network_dev.network_name
    subnetwork        = module.network_dev.subnets_names[0]
    ip_range_pods     = var.ip_range_pods_name
    ip_range_services = var.ip_range_services_name
  })
}

resource "plural_service_context" "prod-vpc" {
  name = "plrl/vpc/prod"

  configuration = jsonencode({
    network           = module.network_prod.network_name
    subnetwork        = module.network_prod.subnets_names[0]
    ip_range_pods     = var.ip_range_pods_name
    ip_range_services = var.ip_range_services_name
  })
}