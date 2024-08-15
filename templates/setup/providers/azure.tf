module "mgmt" {
    source              = "./cluster"
    resource_group_name = "{{ .Project }}"
    cluster_name        = "{{ .Cluster }}"
    location            = "{{ .Region }}"
    create_db           = {{ .RequireDB }}
}