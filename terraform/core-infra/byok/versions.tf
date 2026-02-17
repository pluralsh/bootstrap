terraform {
  required_version = ">= 1.0"

  required_providers {
    plural = {
      source  = "pluralsh/plural"
      version = ">= 0.2.9"
    }
  }
}

provider "plural" {}