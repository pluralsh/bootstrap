module "mgmt" {
    source        = "./cluster"
    project_id    = "{{ .Project }}"
    cluster_name  = "{{ .Cluster }}"
    region        = "{{ .Region }}"
}