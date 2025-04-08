module "gcp-network" {
  source  = "terraform-google-modules/network/google"
  version = ">= 7.5"

  project_id   = var.project_id
  network_name = local.network_name

  subnets = [
    {
      subnet_name   = var.subnetwork
      subnet_ip     = var.subnet_cidr
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    (var.subnetwork) = [
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

resource "google_compute_global_address" "private_ip_alloc" {
  count         = var.create_db ? 1 : 0
  name          = local.range_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.gcp-network.network_id
  project       = var.project_id
}


resource "google_service_networking_connection" "postgres" {
  count                   = var.create_db ? 1 : 0
  network                 = module.gcp-network.network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc[0].name]
  update_on_creation_fail = true
}
