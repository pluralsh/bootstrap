
variable "kubernetes_vsn" {
  type = string
  default = "1.29"
}

variable "cluster" {
  type = string
  default = "test"
}

variable "fleet" {
  type = string
  default = "demo"
}

variable "tier" {
  type = string
  default = "dev"
}

variable "region" {
  type = string
  default = "us-east"
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