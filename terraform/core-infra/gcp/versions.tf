terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
    }
    plural = {
      source = "pluralsh/plural"
      version = ">= 0.2.9"
    }
  }
}

provider "google" {
  project = var.project
  region = var.region
}

data "google_client_config" "default" {}

provider "plural" { }