variable "cluster_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "network_name" {
  type = string
  default = "plural"
}

variable "region" {
  type = string
  default = "us-east-2"
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "client_id" {
  type = string
}

variable "postgres_dns_zone" {
  default = "plrl.postgres.database.azure.com"
}

variable "mysql_dns_zone" {
  default = "plrl.mysql.database.azure.com"
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

variable "mysql_cidrs" {
  type = list(string)
  default = ["10.52.17.0/24"]
}
