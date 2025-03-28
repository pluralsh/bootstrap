terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.51.0, < 4.0"
    }
    plural = {
      source = "pluralsh/plural"
      version = ">= 0.2.9"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  use_cli = false
  use_oidc = true
  oidc_token_file_path = "/var/run/secrets/azure/tokens/azure-identity-token"
  subscription_id = var.subscription_id
  tenant_id = var.tenant_id
  client_id = var.client_id
}

provider "plural" {}
