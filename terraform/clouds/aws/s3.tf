data "aws_region" "current" {}

locals {
  console_object_store_bucket_name = lower(substr(replace("${var.cluster_name}-console-${data.aws_caller_identity.current.account_id}", "_", "-"), 0, 63))
}

resource "aws_s3_bucket" "console" {
  bucket = local.console_object_store_bucket_name
}

resource "aws_s3_bucket_public_access_block" "console" {
  bucket = aws_s3_bucket.console.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "console" {
  bucket = aws_s3_bucket.console.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
