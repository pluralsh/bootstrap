# Variable passthrough to the GCP module in order
# to enable TF_VAR_xxx environment variable usage.
variable "network" { type = string }
variable "subnetwork" { type = string }

module "mgmt" {
    source        = "./cluster"
    project_id    = "{{ .Project }}"
    cluster_name  = "{{ .Cluster }}"
    region        = "{{ .Region }}"
    create_db     = {{ .RequireDB }}
    network       = "${var.network}"
    subnetwork    = "${var.subnetwork}"
}
