terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.0.0"
    }

    plural = {
      source  = "pluralsh/plural"
      version = ">= 0.2.26"
    }
  }
}

provider "aws" {
  region = var.region
}


provider "plural" {}

# Separate provider for plural_cluster, kubeconfig on the default one causes a dependency cycle
# through plural_service_context data sources that the cluster depends on.
provider "plural" {
  alias = "cluster"

  kubeconfig = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}