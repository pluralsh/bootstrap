variable "cluster" {
  type    = string
  default = "plural"
}

variable "fleet" {
  type = string
}

variable "tier" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.34"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.kubernetes_version)) && tonumber(split(".", var.kubernetes_version)[0]) == 1 && tonumber(split(".", var.kubernetes_version)[1]) >= 34
    error_message = "kubernetes_version must be a Kubernetes minor version in major.minor format and at least 1.34."
  }
}

variable "next_kubernetes_version" {
  type        = string
  default     = ""
  description = "AKS control plane target; leave empty to match kubernetes_version."

  validation {
    condition     = var.next_kubernetes_version == "" || (can(regex("^[0-9]+\\.[0-9]+$", var.next_kubernetes_version)) && tonumber(split(".", var.next_kubernetes_version)[0]) == 1 && tonumber(split(".", var.next_kubernetes_version)[1]) >= 34)
    error_message = "next_kubernetes_version must be empty or a Kubernetes minor version in major.minor format and at least 1.34."
  }
}

variable "resource_group_name" {
  type    = string
  default = "plural"
}

variable "workload_identity_enabled" {
  type    = bool
  default = true
}

variable "node_pools" {
  type = map(any)
  default = {
    plural = {
      vm_size             = "Standard_D2s_v3"
      node_count          = 3
      min_count           = 1
      max_count           = 20
      enable_auto_scaling = true
    }
  }
}
