# Plural devboxes: a node pool for Agent Substrate's gVisor workers, the bucket Substrate keeps actor snapshots in,
# and the EKS Pod Identity roles ate-api-server and atelet reach it with. The services in bootstrap/devbox install
# Substrate and the DevboxRunner on top.

variable "devbox_enabled" {
  type    = bool
  default = true
}

variable "devbox_instance_type" {
  type        = string
  default     = "m7i.2xlarge"
  description = "one instance type, since gVisor snapshots need a single CPU model across the pool"
}

variable "devbox_max_nodes" {
  type    = number
  default = 5
}

variable "devbox_data_disk_size" {
  type        = number
  default     = 200
  description = "size in GiB of the gp3 volume mounted at /var/lib/ate"
}

locals {
  devbox       = var.devbox_enabled ? 1 : 0
  devbox_roles = var.devbox_enabled ? toset(["ate-api-server", "atelet"]) : toset([])

  # Joins module.eks.eks_managed_node_groups, so it gets the node security group the rest of the cluster uses.
  devbox_node_groups = var.devbox_enabled ? {
    devbox = {
      instance_types = [var.devbox_instance_type]
      min_size       = 0
      max_size       = var.devbox_max_nodes
      desired_size   = 0

      labels = {
        "plural.sh/devbox-pool" = "devbox"
      }
      taints = {
        sandbox = { key = "ate.dev/sandboxClass", value = "gvisor", effect = "NO_SCHEDULE" }
        # lifted by devbox-disk-prep once the data volume is mounted at /var/lib/ate
        disk = { key = "plural.sh/devbox-disk", value = "pending", effect = "NO_SCHEDULE" }
      }

      block_device_mappings = {
        root = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = 100
            volume_type           = "gp3"
            delete_on_termination = true
            encrypted             = true
          }
        }
        data = {
          device_name = "/dev/xvdb"
          ebs = {
            volume_size           = var.devbox_data_disk_size
            volume_type           = "gp3"
            delete_on_termination = true
            encrypted             = true
          }
        }
      }
    }
  } : {}
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
