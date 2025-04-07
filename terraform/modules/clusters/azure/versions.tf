terraform {
  required_version = ">= 1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.51.0, < 4.0"
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

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  use_cli = false
  use_oidc = true
  oidc_token_file_path = "/var/run/secrets/azure/tokens/azure-identity-token"
  subscription_id = local.identity["subscription_id"]
  tenant_id = local.identity["tenant_id"]
  client_id = local.identity["client_id"]
}

provider "plural" {}
