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
  default = "us-east-2"
}

variable "public" {
  type = bool
  default = true
}

variable "kubernetes_version" {
  type = string
  default = "1.28"
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

variable "node_group_defaults" {
  type = any
  default = {
    instance_types = ["t3.xlarge", "t3a.xlarge"]
    block_device_mappings = [
      {
        device_name = "/dev/xvda"
        ebs = {
          volume_size = 50
          volume_type = "gp3"
          delete_on_termination = true
          encrypted = true
        }
      }
    ]
    disk_size = 50
  }
}

variable "managed_node_groups" {
  type = any
  default = {
    green = {
      use_name_prefix = false
      min_size        = 3
      max_size        = 10
      desired_size    = 3
    }
  }
}