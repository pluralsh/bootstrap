data "plural_service_context" "identity" {
  name = "plrl/azure/identity"
}

data "plural_service_context" "network" {
  name = "plrl/network/${var.tier}"
}

resource "plural_service_context" "cluster" {
  name = "plrl/clusters/${var.cluster}"

  configuration = jsonencode({
    cluster_name = var.cluster
  })
}

resource "plural_cluster" "cluster" {
    provider = plural.cluster

    handle = var.cluster
    name   = var.cluster
  
    tags   = {
      tier = var.tier
      fleet = var.fleet
      role = "workload"
    }

    metadata = jsonencode({
      tier = var.tier
      dns_zone = try(local.network.ingress_dns_zone, "example.com")
      subscription_id = local.identity["subscription_id"]
      tenant_id       = local.identity["tenant_id"]
      resource_group_name = data.azurerm_resource_group.default.name
      
      iam = {
        external_dns = azurerm_user_assigned_identity.dns.client_id
        cert_manager = azurerm_user_assigned_identity.dns.client_id
      }
    })
}
