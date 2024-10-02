variable "cluster_name" {
    type = string
    default = "plural"
}

variable "db_name" {
  type = string
  default = "plural"
}

variable "create_db" {
  type = bool
  default = true
}

variable "kubernetes_version" {
  type = string
  default = "1.29.7"
}

variable "create_resource_group" {
    type = bool
    default = false
}

variable "resource_group_name" {
  type = string
  default = "plural"
}

variable "location" {
  type = string
  default = "centralus"
}

variable "network_name" {
  type = string
  default = "plural"
}

variable "network_cidrs" {
  type = list(string)
  default = ["10.52.0.0/16"]
}

variable "subnet_cidrs" {
  type = list(string)
  default = ["10.52.0.0/20"]
}

variable "postgres_cidrs" {
  type = list(string)
  default = ["10.52.16.0/24"]
}

variable "postgres_disk" {
  type = number
  default = 32768
}

variable "postgres_sku" {
  type = string
  default = "GP_Standard_D4s_v3"
}

variable "db_sku" {
  default = "GP_Gen5_2"
}

variable "workload_identity_enabled" {
  type = bool
  default = false
}

variable "postgres_dns_zone" {
  default = "plrl.postgres.database.azure.com"
}

variable "network_link_name" {
  default = "plrl.postgres.com"
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