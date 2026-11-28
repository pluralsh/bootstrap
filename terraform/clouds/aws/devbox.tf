# Plural devboxes: Karpenter, which runs the node pool for Agent Substrate's workers, the bucket Substrate keeps
# actor snapshots in, and the EKS Pod Identity roles ate-api-server and atelet reach it with. Devbox homes are EBS
# volumes from the EBS CSI driver, snapshotted through the snapshot-controller add-on (runtime.tf). The services in bootstrap/devbox install Karpenter, Substrate and the DevboxRunner on top;
# the devbox NodePool and EC2NodeClass are in services/devbox.
#
# Karpenter rather than a managed node group: a node group spanning zones is one Auto Scaling group whose zone the
# cluster autoscaler can't choose, while Karpenter launches each node in the zone its pending worker needs. It also
# turns on nested virtualization, which EKS drops from managed node groups' launch templates, so the pool can run
# microvm sandboxes as well as gVisor.

variable "devbox_enabled" {
  type    = bool
  default = true
}

locals {
  devbox       = var.devbox_enabled ? 1 : 0
  devbox_roles = var.devbox_enabled ? toset(["ate-api-server", "atelet"]) : toset([])
}

module "devbox_karpenter" {
  count   = local.devbox
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.37"

  cluster_name          = module.eks.cluster_name
  enable_v1_permissions = true

  namespace                       = "karpenter"
  service_account                 = "karpenter"
  create_pod_identity_association = true

  queue_name = substr("${var.cluster_name}-karpenter", 0, 80)

  node_iam_role_name            = substr("${var.cluster_name}-devbox", 0, 64)
  node_iam_role_use_name_prefix = false
  # Karpenter's nodes authenticate their kubelet through this access entry; without it they launch but never register.
  create_access_entry = true
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}

resource "aws_s3_bucket" "devbox" {
  count         = local.devbox
  bucket_prefix = substr("${var.cluster_name}-ate-", 0, 37)
  # snapshots only outlive their devboxes, which go with the cluster
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "devbox" {
  count                   = local.devbox
  bucket                  = aws_s3_bucket.devbox[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "devbox_assume" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "devbox_bucket" {
  count = local.devbox

  statement {
    actions   = ["s3:ListBucket", "s3:GetBucketLocation", "s3:ListBucketMultipartUploads"]
    resources = [aws_s3_bucket.devbox[0].arn]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]
    resources = ["${aws_s3_bucket.devbox[0].arn}/*"]
  }
}

resource "aws_iam_role" "devbox" {
  for_each           = local.devbox_roles
  name               = substr("${var.cluster_name}-${each.key}", 0, 64)
  assume_role_policy = data.aws_iam_policy_document.devbox_assume.json
}

resource "aws_iam_role_policy" "devbox" {
  for_each = local.devbox_roles
  name     = "substrate-snapshots"
  role     = aws_iam_role.devbox[each.key].id
  policy   = data.aws_iam_policy_document.devbox_bucket[0].json
}

resource "aws_eks_pod_identity_association" "devbox" {
  for_each        = local.devbox_roles
  cluster_name    = module.eks.cluster_name
  namespace       = "ate-system"
  service_account = each.key
  role_arn        = aws_iam_role.devbox[each.key].arn
}

output "devbox_snapshot_location" {
  value = try("s3://${aws_s3_bucket.devbox[0].id}/substrate/", "")
}

output "devbox_karpenter_queue" {
  value = try(module.devbox_karpenter[0].queue_name, "")
}

output "devbox_node_role" {
  value = try(module.devbox_karpenter[0].node_iam_role_name, "")
}

output "devbox_subnet_ids" {
  value = join(",", module.vpc.private_subnets)
}

output "devbox_node_security_group_id" {
  value = module.eks.node_security_group_id
}
