terraform {
  required_version = ">= 1.0"

  required_providers {
    plural = {
      source = "pluralsh/plural"
      version = ">= 0.2.16"
    }
  }
}

provider "plural" {
  use_cli = true
}