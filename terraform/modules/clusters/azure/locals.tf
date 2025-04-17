locals {
  identity = jsondecode(data.plural_service_context.identity.configuration)
  network = jsondecode(data.plural_service_context.network.configuration)
}
