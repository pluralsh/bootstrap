terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    plural = {
      source = "pluralsh/plural"
      version = ">= 0.2.26"
    }
    local = {
        source = "hashicorp/local"
    }
  }
}

provider "google" {
  region = var.region
}

data "google_client_config" "default" {}

provider "plural" {}

# Separate provider for plural_cluster, kubeconfig on the default one causes a dependency cycle
# through plural_service_context data sources that the cluster depends on.
provider "plural" {
  alias = "cluster"

  kubeconfig = {
    host = "https://${module.gke.endpoint}"
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
    token = data.google_client_config.default.access_token
  }
}
