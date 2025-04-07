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
  description = "The region to host the cluster in"
  default = "us-east-2"
}

variable "kubernetes_version" {
  type = string
  default = "1.28.9-gke.1000000"
}

variable "resource_group_name" {
  type = string
  default = "pluralsh-test-384515"
}

variable "workload_identity_enabled" {
  type = bool
  default = true
}

variable "node_pools" {
  type = map(any)
  default = {
    plural = {
      vm_size = "Standard_D2s_v3"
      node_count = 3
      min_count = 1
      max_count = 20
      enable_auto_scaling = true
    }
  }
}
