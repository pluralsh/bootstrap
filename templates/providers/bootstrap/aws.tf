terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "{{ .Bucket }}"
    key = "{{ .Cluster }}/bootstrap/terraform.tfstate"
    region = "{{ .Region }}"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.57"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.14.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.2"
    }
    plural = {
      source = "pluralsh/plural"
      version = ">= 0.2.16"
    }
  }
}

provider "aws" {
  region = "{{ .Region }}"
}

data "aws_eks_cluster" "cluster" {
  name = module.mgmt.cluster.cluster_name

  depends_on = [ module.mgmt.cluster ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.mgmt.cluster.cluster_name

  depends_on = [ module.mgmt.cluster ]
}

provider "kubernetes" {
  host                   = module.mgmt.cluster_endpoint
  cluster_ca_certificate = base64decode(module.mgmt.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.mgmt.cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(module.mgmt.cluster.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "plural" {
  use_cli = true # If you want to have a Plural stack manage your console, comment this out and use the `actor` field
}