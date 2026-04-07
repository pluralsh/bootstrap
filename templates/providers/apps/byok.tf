terraform {
  required_version = ">= 1.0"

  backend "local" {}

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    plural = {
      source  = "pluralsh/plural"
      version = ">= 0.2.16"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

data "kubernetes_secret" "console-auth" {
  metadata {
    name      = "console-auth-token"
    namespace = "plrl-console"
  }
}

provider "plural" {
  console_url  = "https://console.{{ .Subdomain }}"
  access_token = data.kubernetes_secret.console-auth.data.access-token
  insecure = true
}

