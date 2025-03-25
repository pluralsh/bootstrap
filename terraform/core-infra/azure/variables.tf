
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