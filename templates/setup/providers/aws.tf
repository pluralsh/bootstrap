module "mgmt" {
    source        = "./cluster"
    cluster_name  = "{{ .Cluster }}"
    create_db     = {{ .RequireDB }}
}