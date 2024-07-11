module "mgmt" {
    source        = "./cluster"
    cluster_name  = "{{ .Cluster }}"
}