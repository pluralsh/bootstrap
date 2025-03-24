variable "region" {
  type = string
  default = "us-east-2"
}

variable "cluster_name" {
  type = string
}

variable "project" {
  type = string
}

variable "network_name" {
  type = string
  default = "plural"
}

variable "pg_subnet_name" {
  type = string
  default = "plural-pg"
}

variable "dns_zone_name" {
  type = string
  default = "plrl.postgres.database.azure.com"
}