terraform {
  backend "gcs" {
    bucket = "{{ .Bucket }}"
    prefix = "{{ .Cluster }}/bootstrap"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.10.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 3.0.0, < 4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
    plural = {
      source  = "pluralsh/plural"
      version = ">= 0.2.26"
    }
  }
  required_version = ">= 0.13"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  alias                  = "bootstrap"
  host                   = module.mgmt.cluster.endpoint
  cluster_ca_certificate = base64decode(module.mgmt.cluster.ca_certificate)
  token                  = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes = {
    host                   = module.mgmt.cluster.endpoint
    cluster_ca_certificate = base64decode(module.mgmt.cluster.ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}

provider "plural" {
  use_cli = var.use_cli # If you want to have a Plural stack manage your console, comment this out and use the `actor` field

  kubeconfig = {
    host                   = module.mgmt.cluster.endpoint
    cluster_ca_certificate = base64decode(module.mgmt.cluster.ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}

## useful outputs dumped here, can be moved to a separate file post-generate
output "console_gcs_bucket" {
  value = module.mgmt.console_gcs_bucket
}

output "console_gcs_project" {
  value = module.mgmt.console_gcs_project
}

output "console_gcs_service_account" {
  value = module.mgmt.console_gcs_service_account
}

variable "use_cli" {
  type    = bool
  default = true
}
