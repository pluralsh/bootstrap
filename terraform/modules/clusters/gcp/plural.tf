resource "plural_cluster" "this" {
    handle = var.cluster
    name   = var.cluster
  
    tags   = {
      tier = var.tier
      fleet = var.fleet
      role = "workload"
    }

    kubeconfig = {
      host = "https://${module.gke.endpoint}"
      cluster_ca_certificate = base64decode(module.gke.ca_certificate)
      token = data.google_client_config.default.access_token
    }

    depends_on = [ module.gcp-network ]
}
