variable "region" {
  type = string
  default = "us-east-2"
}

variable "cluster_name" {
    type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]
}

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}