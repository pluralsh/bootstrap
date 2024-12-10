variable "deletion_protection" {
    type    = bool
    default = true
}

module "mgmt" {
    source        = "./cluster"
    cluster_name  = "{{ .Cluster }}"
    create_db     = {{ .RequireDB }}
    deletion_protection = "${var.deletion_protection}"
}

