variable "cluster_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "region" {
  type = string
  default = "us-east-2"
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

variable "postgres_dns_zone" {
  default = "plrl.postgres.database.azure.com"
}

variable "network_link_name" {
  default = "plrl.postgres.com"
}
