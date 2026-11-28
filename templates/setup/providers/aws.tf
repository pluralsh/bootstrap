variable "deletion_protection" {
    type    = bool
    default = true
}

module "mgmt" {
    source        = "./cluster"
    cluster_name  = "{{ .Cluster }}"
    admin_arn = "{{ .Context.IAMSession }}"
    create_db     = {{ .RequireDB }}
    deletion_protection = "${var.deletion_protection}"
}


# read by the devbox services in bootstrap/devbox through the mgmt stack's outputs
output "devbox_snapshot_location" {
  value = module.mgmt.devbox_snapshot_location
}

output "cluster_name" {
  value = module.mgmt.cluster_name
}

output "cluster_endpoint" {
  value = module.mgmt.cluster_endpoint
}

output "devbox_karpenter_queue" {
  value = module.mgmt.devbox_karpenter_queue
}

output "devbox_node_role" {
  value = module.mgmt.devbox_node_role
}

output "devbox_subnet_ids" {
  value = module.mgmt.devbox_subnet_ids
}

output "devbox_node_security_group_id" {
  value = module.mgmt.devbox_node_security_group_id
}
