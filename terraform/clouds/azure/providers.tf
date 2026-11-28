terraform {
  required_version = ">=1.3"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.51.0, < 4.0"
    }
    # 1.x, as the AKS module pins it
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.13, < 2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9"
    }
  }
}
