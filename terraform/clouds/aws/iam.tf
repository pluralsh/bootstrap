// Permissions for the stacks
resource "aws_iam_role" "stacks_role" {
  name = "${var.cluster_name}-plrl-stacks"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEksAuthToAssumeRoleForPodIdentity"
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "stacks_policy_attach" {
  role       = aws_iam_role.stacks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
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
        Sid    = "AllowEksAuthToAssumeRoleForPodIdentity"
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
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
        Sid    = "AllowEksAuthToAssumeRoleForPodIdentity"
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
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

module "externaldns_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.33"

  role_name                  = "${var.cluster_name}-externaldns"
  attach_external_dns_policy = true
  attach_cert_manager_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns", "cert-manager:cert-manager"]
    }
  }
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
      "route53:ListTagsForResources",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "cert_manager" {
  statement {
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]

    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    actions   = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "external_dns_role" {
  name = "${var.cluster_name}-external-dns"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEksAuthToAssumeRoleForPodIdentity"
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "external_dns" {
  name_prefix = "external-dns"
  description = "external dns permissions for ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.external_dns.json
}

resource "aws_iam_role_policy_attachment" "external_dns_policy_attach" {
  role       = aws_iam_role.external_dns_role.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "aws_iam_role" "cert_manager_role" {
  name = "${var.cluster_name}-cert-manager"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEksAuthToAssumeRoleForPodIdentity"
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "cert_manager" {
  name_prefix = "cert-manager"
  description = "cert manager permissions for ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.cert_manager.json
}

resource "aws_iam_role_policy_attachment" "cert_manager_policy_attach" {
  role       = aws_iam_role.cert_manager_role.name
  policy_arn = aws_iam_policy.cert_manager.arn
}

resource "aws_eks_pod_identity_association" "cert_manager_pod_identity" {
  cluster_name    = module.eks.cluster_name
  namespace       = "cert-manager"
  service_account = "cert-manager"
  role_arn        = aws_iam_role.cert_manager_role.arn
}

resource "aws_eks_pod_identity_association" "external_dns_pod_identity" {
  cluster_name    = module.eks.cluster_name
  namespace       = "external-dns"
  service_account = "external-dns"
  role_arn        = aws_iam_role.external_dns_role.arn
}
