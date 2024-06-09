module "mgmt" {
    source        = "../terraform/modules/mgmt"
    project_id    = "{{ .Project }}"
    cluster_name  = "{{ .Cluster }}"
    region        = "{{ .Region }}"
}