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