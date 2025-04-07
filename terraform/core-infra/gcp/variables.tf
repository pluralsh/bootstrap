variable "project" {
  type = string
}

variable "region" {
  type = string
  default = "us-east-2"
}

variable "cluster_name" {
    type = string
}

variable "subnet_cidr" {
  type = string
  default = "10.0.16.0/20"
}

variable "pods_cidr" {
  type = string
  default = "10.16.0.0/12"
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