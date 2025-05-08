terraform {
  required_version = ">= 1.0"

  backend "s3" {
    endpoint = "us-east-1.linodeobjects.com"
    bucket = "{{ .Bucket }}"
    key = "{{ .Cluster }}/bootstrap/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 2.13.0" 
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
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
      version = ">= 0.2.0"
    }
  }
}

provider "linode" {}

module "parsed" {
    source = "../bootstrap/terraform/modules/raw-kubeconfig"
    kubeconfig = module.mgmt.cluster.kubeconfig
}

provider "helm" {
  kubernetes {
    host                   = module.parsed.cluster.server
    cluster_ca_certificate = base64decode(module.parsed.cluster.certificate-authority-data)
    token                  = module.parsed.user.token
  }
}

provider "plural" {
  use_cli = var.use_cli # If you want to have a Plural stack manage your console, comment this out and use the `actor` field
}

variable "use_cli" {
  type = bool
  default = true
}