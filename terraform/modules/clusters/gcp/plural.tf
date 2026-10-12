resource "plural_cluster" "this" {
    provider = plural.cluster

    handle = var.cluster
    name   = var.cluster
  
    tags   = {
      tier = var.tier
      fleet = var.fleet
      role = "workload"
    }

    metadata = jsonencode({
      project = local.project_id
      tier = var.tier
      dns_zone = try(local.vpc.ingress_dns_zone, "example.com")
      iam = {
        external_dns = google_service_account.externaldns.email
      }
    })
}
