

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "cluster_oidc_issuer_arn" {
  type        = string
  description = "The OIDC issuer URL of the EKS cluster"
}

variable "certmanager_serviceaccount" {
  type        = string
  default     = "certmanager"
  description = "name of the certmanager service account"
}

variable "namespace" {
  type    = string
  default = "bootstrap"
}

variable "externaldns_serviceaccount" {
  type        = string
  default     = "externaldns"
  description = "name of the external dns service account"
}

variable "externaldns_namespace" {
  type        = string
  default     = "plrl-runtime"
  description = "name of the external dns namespace"
}
