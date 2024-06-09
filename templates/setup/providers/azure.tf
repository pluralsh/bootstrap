module "mgmt" {
    source              = "../terraform/modules/mgmt"
    resource_group_name = "{{ .Project }}"
    cluster_name        = "{{ .Cluster }}"
    location            = "{{ .Region }}"
}