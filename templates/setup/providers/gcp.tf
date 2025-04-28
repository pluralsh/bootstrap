# Variable passthrough to the GCP module in order
# to enable TF_VAR_xxx environment variable usage.
variable "network" {
  type = string
  description = "The VPC network created to host the cluster in"
  default     = "plural-core"
}

variable "subnetwork" {
  type = string
  description = "The subnetwork created to host the cluster in"
  default     = "plural-core"
}

module "mgmt" {
    source        = "./cluster"
    project_id    = "{{ .Project }}"
    cluster_name  = "{{ .Cluster }}"
    region        = "{{ .Region }}"
    create_db     = {{ .RequireDB }}
    network       = "${var.network}"
    subnetwork    = "${var.subnetwork}"
}
