terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    plural = {
      source = "pluralsh/plural"
      version = ">= 0.2.9"
    }
  }
}

provider "aws" {
  region = var.region
}


provider "plural" {}