variable "region" {
  type = string
  default = "us-east" 
}

variable "create_db" {
  type = bool
  default = true
}

variable "cluster_name" {
  type = string
  default = "plural"
}

variable "db_size" {
  type = string
  default = "g6-standard-2"
}

variable "db_allowlist" {
  type = list(string)
  default = ["0.0.0.0/0"]
}

variable "engine_id" {
  type = string
  default = "postgresql/13.2"
}

variable "kubernetes_vsn" {
  type = string
  default = "1.34"
}

variable "node_pools" {
  type = list(any)
  default = [ 
    {
        type="g6-standard-2",
        count=3
        autoscaler={
            min=3
            max=20
        }
    }
  ]
}