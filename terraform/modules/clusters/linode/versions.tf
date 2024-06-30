terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.20.1" 
    }
    plural = {
      source = "pluralsh/plural"
      version = ">= 0.2.9"
    }
  }
}

provider "plural" { }

provider "linode" { }