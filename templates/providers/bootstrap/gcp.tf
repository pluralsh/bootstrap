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
      version = "3.6.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.14.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.2"
    }
    plural = {
      source = "pluralsh/plural"
      version = ">= 0.2.16"
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

provider "plural" {
  use_cli = true # If you want to have a Plural stack manage your console, comment this out and use the `actor` field
}