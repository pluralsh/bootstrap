terraform {
  required_version = ">= 1.0"

  backend "s3" {
    endpoint = "us-east-1.linodeobjects.com"
    bucket = "{{ .Bucket }}"
    key = "{{ .Cluster }}/apps/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 2.23.0" 
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
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

provider "kubernetes" {
  host                   = module.parsed.cluster.server
  cluster_ca_certificate = base64decode(module.parsed.cluster.certificate-authority-data)
  token                  = module.parsed.user.token
}

data "kubernetes_secret" "console-auth" {
  metadata {
    name = "console-auth-token"
    namespace = "plrl-console"
  }
}

provider "plural" {
  console_url = "https://console.{{ .Subdomain }}"
  access_token = data.kubernetes_secret.console-auth.data.access-token
}