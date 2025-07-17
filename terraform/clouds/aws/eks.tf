data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = data.aws_caller_identity.current.arn
}

data "aws_partition" "current" {}

locals {
  cluster_admin_policy = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  stacks_arn           = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.cluster_name}-plrl-stacks"

  bg_taint = [
    {
      key    = "platform.plural.sh/draining"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  ]

  node_pool_add = {
    (local.active_node_group) = {
      cluster_version = var.kubernetes_version,
      taints = local.upgrading ? local.bg_taint : [],
    },
    (local.drain_node_group) =  {
      cluster_version = var.next_kubernetes_version,
    }
  }

  full_node_groups = {for k, v in var.managed_node_groups: k => merge(v, try(lookup(local.node_pool_add, k), {})) if k != local.drain_node_group || local.upgrading == true}
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.next_kubernetes_version

  cluster_endpoint_public_access = var.public

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  create_kms_key = true

  enable_cluster_creator_admin_permissions = false

  access_entries = {
    admin = {
      principal_arn  = var.admin_arn
      type          = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn = "arn:${data.aws_partition.current.partition}:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    stacks = {
      principal_arn = local.stacks_arn
      type          = "STANDARD"
      policy_associations = {
        admin = {
          policy_arn = local.cluster_admin_policy
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  kms_key_administrators = concat([
    data.aws_iam_session_context.current.issuer_arn
  ], var.additional_kms_administrators)

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = var.node_group_defaults
  eks_managed_node_groups = local.full_node_groups

  create_cloudwatch_log_group = var.create_cloudwatch_log_group

  depends_on = [ module.vpc.nat_ids ] # This ensures that the VPC NAT gateways are created before the EKS cluster
}
