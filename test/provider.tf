terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">= 6.10.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.3.2"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.12.1"
    }
  }
  required_version = ">= 0.13"
}

data "google_client_config" "current" {}

# provider "kubernetes" {
#   host                   = "https://${module.gcp.cluster.endpoint}"
#   token                  = data.google_client_config.default.access_token
#   cluster_ca_certificate = base64decode(module.gcp.cluster.ca_certificate)
# }

provider "helm" {
  kubernetes {
    host                   = module.gcp.cluster.endpoint
    cluster_ca_certificate = base64decode(module.gcp.cluster.ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
}
