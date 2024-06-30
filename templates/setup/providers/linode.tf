module "mgmt" {
    source       = "./cluster"
    cluster_name = "{{ .Cluster }}"
    region       = "{{ .Region }}"
}