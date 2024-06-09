module "mgmt" {
    source        = "../terraform/modules/mgmt"
    cluster_name  = "{{ .Cluster }}"
}