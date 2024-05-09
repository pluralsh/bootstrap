module "assumable_role_certmanager" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version          = "3.14.0"
  create_role      = true
  role_name        = "${var.cluster_name}-certmanager-extdns"
  provider_url     = var.cluster_oidc_issuer_arn
  role_policy_arns = [aws_iam_policy.certmanager.arn]
  oidc_fully_qualified_subjects = [
    "system:serviceaccount:${var.externaldns_namespace}:${var.externaldns_serviceaccount}",
    "system:serviceaccount:${var.namespace}:${var.certmanager_serviceaccount}"
  ]
}

resource "aws_iam_policy" "certmanager" {
  name_prefix = "certmanager"
  description = "certmanager permissions for ${var.cluster_name}"
  policy      = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "route53:GetChange",
          "Resource": "arn:aws:route53:::change/*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets",
            "route53:ListHostedZones"
          ],
          "Resource": "arn:aws:route53:::hostedzone/*"
        },
        {
          "Effect": "Allow",
          "Action": "route53:ListHostedZones",
          "Resource": "*"
        }
      ]
    }
  POLICY
}
