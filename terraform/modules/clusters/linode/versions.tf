terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.20.1" 
    }
    plural = {
      source = "pluralsh/plural"
      version = ">= 0.2.26"
    }
  }
}

provider "plural" {
  kubeconfig = {
    host = local.cluster.server
    cluster_ca_certificate = base64decode(local.cluster["certificate-authority-data"])
    token = local.user.token
  }
}

provider "linode" { }