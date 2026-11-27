module "mgmt" {
    source              = "./cluster"
    resource_group_name = "{{ .Project }}"
    cluster_name        = "{{ .Cluster }}"
    location            = "{{ .Region }}"
    create_db           = {{ .RequireDB }}
}
# read by the devbox services in bootstrap/devbox through the mgmt stack's outputs
output "devbox_snapshot_location" {
  value = module.mgmt.devbox_snapshot_location
}

output "devbox_account_url" {
  value = module.mgmt.devbox_account_url
}

output "devbox_tenant_id" {
  value = module.mgmt.devbox_tenant_id
}

output "devbox_node_client_id" {
  value = module.mgmt.devbox_node_client_id
}

output "devbox_control_client_id" {
  value = module.mgmt.devbox_control_client_id
}

output "devbox_zerofs_client_id" {
  value = module.mgmt.devbox_zerofs_client_id
}
