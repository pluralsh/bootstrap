terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.0.0"
    }

    plural = {
      source = "pluralsh/plural"
      version = ">= 0.2.9"
    }

    helm = {
      source = "hashicorp/helm"
      version = "< 3.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}


provider "plural" { }