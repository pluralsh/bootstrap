// Permissions for the stacks
resource "aws_iam_role" "stacks_role" {
  name = "${var.cluster_name}-plrl-stacks"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
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

resource "aws_iam_role_policy_attachment" "stacks_policy_attach" {
  role       = aws_iam_role.stacks_role.name
  policy_arn = aws_iam_policy.stacks.arn
}

resource "aws_eks_pod_identity_association" "stacks_pod_identity" {
  cluster_name    = module.eks.cluster_name
  namespace       = "plrl-deploy-operator"
  service_account = "stacks"
  role_arn        = aws_iam_role.stacks_role.arn
}

// Permissions for the upgrade insights
resource "aws_iam_role" "eks_insights_role" {
  name = "${var.cluster_name}-plrl-insights"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
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
            "eks:DescribeInsight",
            "eks:ListAddons",
            "eks:DescribeAddon"
          ],
          "Effect": "Allow",
          "Resource": "*"
        }
      ]
    }
  POLICY
}

resource "aws_iam_role_policy_attachment" "eks_upgrade_insights" {
  role       = aws_iam_role.eks_insights_role.name
  policy_arn = aws_iam_policy.eks_upgrade_insights.arn
}

resource "aws_eks_pod_identity_association" "eks_insights_pod_identity" {
  cluster_name    = module.eks.cluster_name
  namespace       = "plrl-deploy-operator"
  service_account = "deployment-operator"
  role_arn        = aws_iam_role.eks_insights_role.arn
}

// Permissions for the cloudwatch exporter
resource "aws_iam_role" "cloudwatch_exporter_role" {
  name = "${var.cluster_name}-cloudwatch-exporter"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
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

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attach" {
  role       = aws_iam_role.cloudwatch_exporter_role.name
  policy_arn = aws_iam_policy.cloudwatch.arn
}

resource "aws_eks_pod_identity_association" "cloudwatch_pod_identity" {
  cluster_name    = module.eks.cluster_name
  namespace       = "monitoring"
  service_account = "cloudwatch-exporter"
  role_arn        = aws_iam_role.cloudwatch_exporter_role.arn
}
