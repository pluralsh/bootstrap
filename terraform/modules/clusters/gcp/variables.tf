variable "cluster" {
  type = string
  default = "plural"
}

variable "fleet" {
  type = string
}

variable "tier" {
  type = string
}

variable "region" {
  type = string
  default = "us-east-2"
}

variable "kubernetes_version" {
  type = string
  default = "1.28.9-gke.1000000"
}

variable "node_pools" {
  type = list(any)
  default = [ {name = "default-node-pool"} ]
}

variable "node_pools_taints" {
  type = map(list(object({ key = string, value = string, effect = string })))
  default = { "all": [], "default-node-pool": [] }
}

variable "node_pools_labels" {
  type = map(map(string))
  default = { "all": {}, "default-node-pool": {} }
}

variable "node_pools_tags" {
  type = map(list(string))
  default = { "all": [], "default-node-pool": [] }
}

variable "project_id" {
  type = string
  default = "pluralsh-test-384515"
}

variable "region" {
  type = string
  description = "The region to host the cluster in"
  default     = "us-central1"
}

variable "network" {
  type = string
  description = "The VPC network created to host the cluster in"
  default     = "plural-network"
}

variable "subnetwork" {
  type = string
  description = "The subnetwork created to host the cluster in"
  default     = "plural-subnet"
}

variable "subnet_cidr" {
  type = string
  default = "10.0.16.0/20"
}

variable "pods_cidr" {
  type = string
  default = "10.16.0.0/12"
}

variable "allocated_range_name" {
  type = string
  default = ""
}

variable "services_cidr" {
  type = string
  default = "10.1.0.0/20"
}

variable "ip_range_pods_name" {
  type = string
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}

variable "ip_range_services_name" {
  type = string
  description = "The secondary ip range to use for services"
  default     = "ip-range-svc"
}

variable "tags" {
  type = map(string)
  default = {}
}