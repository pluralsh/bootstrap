data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = try(data.aws_caller_identity.current[0].arn, "")
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  cluster_endpoint_public_access = var.public

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.public_subnets

  create_kms_key = true

  kms_key_administrators = concat([
    module.assumable_role_stacks.iam_role_arn,
    try(data.aws_iam_session_context.current[0].issuer_arn, "")
  ], var.additional_kms_administrators)

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = merge(var.node_group_defaults,
    {ami_release_version = data.aws_ssm_parameter.eks_ami_release_version.value})

  eks_managed_node_groups = var.managed_node_groups

  create_cloudwatch_log_group = var.create_cloudwatch_log_group
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2/recommended/release_version"
}