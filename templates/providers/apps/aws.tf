terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket = "{{ .Bucket }}"
    key = "{{ .Cluster }}/apps/terraform.tfstate"
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
  name = "{{ .Cluster }}"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "{{ .Cluster }}"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "kubernetes_secret" "console-auth" {
  metadata {
    name = "console-auth-token"
    namespace = "plrl-console"
  }
}

provider "plural" {
  console_url = "https://console.{{ .Subdomain }}"
  access_token = data.kubernetes_secret.console-auth.data.access-token
}