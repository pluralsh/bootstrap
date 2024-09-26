resource "aws_iam_role_policy_attachment" "eks_upgrade_insights" {
  for_each   = module.eks.eks_managed_node_groups
  role       = each.value.iam_role_name
  policy_arn = aws_iam_policy.eks_upgrade_insights.arn
}

resource "aws_iam_policy" "eks_upgrade_insights" {
  name_prefix = "eks-upgrade-insights"
  description = "eks upgrade insights permissions for ${var.cluster}"
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