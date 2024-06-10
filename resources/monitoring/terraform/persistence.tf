variable "acl" {
  type    = string
  default = "private"
}

variable "prefix" {
  type    = string
  default = "loki"
}

variable "enable_versioning" {
  type    = bool
  default = false
}

variable "cluster_name" {
  type    = string
  default = "boot-test"
}

variable "loki_service_account" {
  type    = string
  default = "loki"
}

variable "namespace" {
  type    = string
  default = "monitoring"
}

###############################################

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.cluster_name}-${var.prefix}-storage"
  #acl           = var.acl # deprecated
  force_destroy = true
}


resource "aws_iam_policy" "iam_policy" {
  name_prefix = var.prefix
  description = "policy for ${var.prefix} s3 access"
  policy      = data.aws_iam_policy_document.admin.json
}

resource "aws_s3_bucket_versioning" "version" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

data "aws_iam_policy_document" "admin" {
  statement {
    sid     = "admin"
    effect  = "Allow"
    actions = ["s3:*"]

    resources = concat(
      ["arn:aws:s3:::${aws_s3_bucket.bucket.id}"],
      ["arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"]
    )
  }
}

#data "aws_eks_cluster" "cluster" {
#  name = var.cluster_name
#}

module "assumable_role_loki" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.37.2"
  create_role                   = true
  role_name                     = "${var.cluster_name}-${var.loki_service_account}"
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.loki_service_account}"]
  provider_url                  = replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")
  role_policy_arns              = [aws_iam_policy.iam_policy.arn]
}

resource "plural_service_context" "loki" {
  name = "loki"
  configuration = {
    roleArn    = module.assumable_role_loki.iam_role_arn
    bucketName = aws_s3_bucket.bucket.id
  }
}

