resource "plural_cluster" "this" {
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

    kubeconfig = {
      host = "https://${module.gke.endpoint}"
      cluster_ca_certificate = base64decode(module.gke.ca_certificate)
      token = data.google_client_config.default.access_token
    }
}
