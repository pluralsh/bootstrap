terraform {
  required_version = ">= 1.0"

  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 2.12.0"
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
      version = "2.4.1"
    }
  }
}

provider "linode" {}

module "parsed" {
  source     = "../../terraform/modules/raw-kubeconfig"
  kubeconfig = module.mgmt.cluster.kubeconfig
}

provider "helm" {
  kubernetes = {
    host                   = module.parsed.cluster.server
    cluster_ca_certificate = base64decode(module.parsed.cluster.certificate-authority-data)
    token                  = module.parsed.user.token
  }
}