data "plural_service_context" "identity" {
  name = "plrl/azure/identity"
}

data "plural_service_context" "network" {
  name = "plrl/network/${var.tier}"
}

resource "plural_service_context" "cluster" {
  name = "plrl/clusters/${var.cluster}"

  configuration = jsonencode({
    cluster_name = var.cluster
  })
}

resource "plural_cluster" "cluster" {
    handle = var.cluster
    name   = var.cluster
  
    tags   = {
      tier = var.tier
      fleet = var.fleet
      role = "workload"
    }

    kubeconfig = {
      host =  module.aks.cluster_fqdn
      cluster_ca_certificate = base64decode(module.aks.cluster_ca_certificate)
      client_certificate     = base64decode(module.aks.client_certificate)
      client_key             = base64decode(module.aks.client_key)
    }
}
