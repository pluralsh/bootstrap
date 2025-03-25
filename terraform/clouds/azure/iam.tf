resource "azurerm_role_assignment" "aks-network-identity-kubelet" {
  scope                = azurerm_virtual_network.network.id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.kubelet_identity[0].object_id

  depends_on = [module.aks, azurerm_virtual_network.network]
}

resource "azurerm_role_assignment" "aks-network-identity-ssi" {
  scope                = azurerm_virtual_network.network.id
  role_definition_name = "Network Contributor"
  principal_id         = module.aks.cluster_identity.principal_id

  depends_on = [module.aks, azurerm_virtual_network.network]
}

resource "azurerm_user_assigned_identity" "stacks" {
  resource_group_name = local.resource_group.name
  location            = local.resource_group.location

  name = "${var.cluster_name}-plrl-stacks"
}

resource "azurerm_role_assignment" "stacks-ssi" {
  scope                = local.rg.id
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.stacks.principal_id
}

resource "azurerm_federated_identity_credential" "stacks" {
  name                = "${var.cluster_name}-stacks"
  resource_group_name = local.resource_group.name
  audience = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.stacks.id
  subject             = "system:serviceaccount:plrl-deploy-operator:stacks"
}

data "azurerm_subscription" "current" {}

resource "plural_service_context" "identity" {
  name = "plrl/azure/identity"
  configuration = jsonencode({
    subscription_id = data.azurerm_subscription.current.subscription_id
    tenant_id       = azurerm_user_assigned_identity.stacks.tenant_id
    client_id       = azurerm_user_assigned_identity.stacks.client_id
  })
}
