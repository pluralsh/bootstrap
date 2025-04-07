data "azurerm_resource_group" "default" {
  name = var.resource_group_name
}

resource "azurerm_user_assigned_identity" "dns" {
  name                = "${var.cluster}-dns"
  resource_group_name = data.azurerm_resource_group.default.name
  location            = data.azurerm_resource_group.default.location
}

resource "azurerm_role_assignment" "dns-reader" {
  scope                = data.azurerm_resource_group.default.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.dns.principal_id
}

resource "azurerm_role_assignment" "dns-zone-contributor" {
  scope                = data.azurerm_resource_group.default.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.dns.principal_id
}

resource "azurerm_federated_identity_credential" "plural-runtime" {
  name                = "${var.cluster}-plural-runtime"
  resource_group_name = data.azurerm_resource_group.default.name
  audience = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.dns.id
  subject             = "system:serviceaccount:plural-runtime:external-dns"
}

resource "azurerm_federated_identity_credential" "external-dns" {
  name                = "${var.cluster}-external-dns"
  resource_group_name = data.azurerm_resource_group.default.name
  audience = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.dns.id
  subject             = "system:serviceaccount:external-dns:external-dns"
}

resource "azurerm_federated_identity_credential" "cert-manager" {
  name                = "${var.cluster}-cert-manager"
  resource_group_name = data.azurerm_resource_group.default.name
  audience = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.dns.id
  subject             = "system:serviceaccount:cert-manager:cert-manager"
}
