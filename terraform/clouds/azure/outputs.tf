output "cluster" {
    value = module.aks
}

output "network" {
    value = azurerm_virtual_network.network
}

output "db" {
    value = azurerm_postgresql_flexible_server.postgres
}

output "db_url" {
    value = local.db_url
    sensitive = true
}

output "ready" {
    value = module.aks
}

output "identity" {
    value = azurerm_user_assigned_identity.stacks.client_id
}


output "console_azure_storage_account" {
  value = azurerm_storage_account.console.name
}

output "console_azure_container" {
  value = azurerm_storage_container.console.name
}

output "console_azure_client_id" {
  value = azurerm_user_assigned_identity.console.client_id
}
