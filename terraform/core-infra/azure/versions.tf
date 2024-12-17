terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    plural = {
      source = "pluralsh/plural"
      version = ">= 0.2.9"
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

provider "plural" { }