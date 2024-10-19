module "assumable_role_stacks" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version          = "5.39.1"
  create_role      = true
  role_name        = "${var.cluster_name}-plrl-stacks"
  provider_url     = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [aws_iam_policy.stacks.arn]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:plrl-deploy-operator:stacks",
  ]
}

resource "aws_iam_policy" "stacks" {
  name_prefix = "stacks"
  description = "stacks permissions for ${var.cluster_name}"
  policy      = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "*",
          "Resource": "*"
        }
      ]
    }
  POLICY
}

resource "aws_iam_role_policy_attachment" "eks_upgrade_insights" {
  for_each   = module.eks.eks_managed_node_groups
  role       = each.value.iam_role_name
  policy_arn = aws_iam_policy.eks_upgrade_insights.arn
}

resource "aws_iam_policy" "eks_upgrade_insights" {
  name_prefix = "eks-upgrade-insights"
  description = "eks upgrade insights permissions for ${var.cluster_name}"
  policy      = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "eks:ListInsights",
            "eks:DescribeInsight"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    }
  POLICY
}

module "assumable_role_cloudwatch_exporter" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version          = "5.39.1"
  create_role      = true
  role_name        = "${var.cluster_name}-cloudwatch-exporter"
  provider_url     = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns = [aws_iam_policy.cloudwatch.arn]
  oidc_subjects_with_wildcards = [
    "system:serviceaccount:monitoring:cloudwatch-exporter*",
  ]
}

resource "aws_iam_policy" "cloudwatch" {
  name_prefix = "cloudwatch-exporter"
  description = "cloudwatch exporter permissions for ${var.cluster_name}"
  policy      = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "tag:GetResources",
            "cloudwatch:GetMetricData",
            "cloudwatch:GetMetricStatistics",
            "cloudwatch:ListMetrics",
            "apigateway:GET",
            "aps:ListWorkspaces",
            "autoscaling:DescribeAutoScalingGroups",
            "dms:DescribeReplicationInstances",
            "dms:DescribeReplicationTasks",
            "ec2:DescribeTransitGatewayAttachments",
            "ec2:DescribeSpotFleetRequests",
            "shield:ListProtections",
            "storagegateway:ListGateways",
            "storagegateway:ListTagsForResource",
            "iam:ListAccountAliases"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    }
  POLICY
}