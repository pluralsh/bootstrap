locals {
  # Azure storage account names: 3-24 chars, lowercase alphanumeric only.
  # Include a subscription-id fragment for global uniqueness (mirrors S3/GCS account/project suffix).
  console_storage_account_name = substr(
    join("", regexall("[a-z0-9]", lower(format("%sconsole%s", var.cluster_name, replace(data.azurerm_subscription.current.subscription_id, "-", ""))))),
    0,
    24
  )
  console_storage_container_name = "console"
}

resource "azurerm_storage_account" "console" {
  name                            = local.console_storage_account_name
  resource_group_name             = local.resource_group.name
  location                        = local.resource_group.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  enable_https_traffic_only       = true
}

resource "azurerm_storage_container" "console" {
  name                  = local.console_storage_container_name
  storage_account_name  = azurerm_storage_account.console.name
  container_access_type = "private"
}

# Dedicated UAMI for the console KSA (plrl-console/console). Do not reuse
# azurerm_user_assigned_identity.stacks — that binds stacks with Owner.
resource "azurerm_user_assigned_identity" "console" {
  name                = "${var.cluster_name}-plrl-console"
  resource_group_name = local.resource_group.name
  location            = local.resource_group.location
}

resource "azurerm_role_assignment" "console_blob_data_contributor" {
  scope                = azurerm_storage_account.console.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.console.principal_id
}

resource "azurerm_federated_identity_credential" "console" {
  name                = "${var.cluster_name}-console"
  resource_group_name = local.resource_group.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.console.id
  subject             = "system:serviceaccount:plrl-console:console"
}
