variable "cluster_name" {
  type    = string
  default = "plural"
}

variable "db_name" {
  type    = string
  default = ""
}

variable "db_storage" {
  type = number
  default = 20
}

variable "postgres_vsn" {
  type = string
  default = "14"
}

variable "create_db" {
  type    = bool
  default = true
}

variable "kubernetes_version" {
  type    = string
  default = "1.32"
}

variable "next_kubernetes_version" {
  type    = string
  default = "1.32"
}

variable "public" {
  type    = bool
  default = true
}

variable "vpc_name" {
  type    = string
  default = ""
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

variable "deletion_protection" {
  type    = bool
  default = true
}

variable "backup_retention_period" {
  type = number
  default = 7
}

variable "db_instance_class" {
  default = "db.t4g.large"
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
      use_name_prefix = false // TODO: True?
      min_size        = 0
      max_size        = 10
      desired_size    = 3
    }
    blue = {
      use_name_prefix = false // TODO: True?
      min_size        = 0
      max_size        = 10
      desired_size    = 3 // TODO: Remove?
    }
  }
}

variable "create_cloudwatch_log_group" {
  type = bool
  default = false
}

variable "monitoring_role" {
  type = string
  default = ""
}

variable "additional_kms_administrators" {
  type = list(string)
  default = [ ]
}