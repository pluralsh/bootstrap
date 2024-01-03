terraform {
  backend "gcs" {
    bucket = "{{ .Bucket }}"
    prefix = "{{ .Cluster }}/apps"
  }

  required_providers {
    google = {
      source = "hashicorp/google"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    plural = {
      source = "pluralsh/plural"
      version = ">= 0.0.1"
    }
  }
  required_version = ">= 0.13"
}

data "google_client_config" "default" {}

data "google_container_cluster" "cluster" {
  name = "{{ .Cluster }}"
  location = "{{ .Region }}"
}

provider "kubernetes" {
  host = data.google_container_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)
  token = data.google_client_config.current.access_token
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