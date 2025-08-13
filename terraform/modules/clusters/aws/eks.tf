data "plural_service_context" "network" {
  name = "plrl/vpc/${var.tier}"
}

locals {
  vpc = jsondecode(data.plural_service_context.network.configuration)
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access = var.public

  vpc_id                   = local.vpc.vpc_id
  subnet_ids               = local.vpc.private_subnets
  control_plane_subnet_ids = local.vpc.public_subnets

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = merge(var.node_group_defaults,
    {ami_release_version = data.aws_ssm_parameter.eks_ami_release_version.value})

  eks_managed_node_groups = var.managed_node_groups

  create_cloudwatch_log_group = false
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2023/x86_64/standard/recommended/release_version"
}