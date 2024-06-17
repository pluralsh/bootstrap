terraform {
  backend "gcs" {
    bucket = "{{ .Bucket }}"
    prefix = "{{ .Cluster }}/bootstrap"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.12.1"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.1"
    }
  }
  required_version = ">= 0.13"
}

data "google_client_config" "default" {}

provider "helm" {
  kubernetes {
    host                   = module.mgmt.cluster.endpoint
    cluster_ca_certificate = base64decode(module.mgmt.cluster.ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}