resource "plural_service_context" "identity" {
  name = "plrl/azure/identity"
  configuration = jsonencode({
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id
    client_id       = var.client_id
  })
}
