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
