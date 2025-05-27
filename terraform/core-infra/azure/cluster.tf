resource "plural_service_context" "mgmt" {
  name = "plrl/clusters/mgmt"
  configuration = jsonencode({
    region       = var.region
    cluster_name = var.cluster_name
    resource_group_name = var.resource_group_name
  })
}
