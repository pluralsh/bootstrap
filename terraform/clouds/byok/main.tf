# BYOK stub cluster module.
# The cluster already exists externally; this module only supplies the output
# attributes that console.tf depends on so that file can be used unchanged
# across all providers.

# Optional external database URL. Leave empty to run the console without a
# managed database (SQLite / in-cluster DB depending on the console chart).
variable "db_url" {
  type      = string
  default   = ""
  sensitive = true
}

resource "null_resource" "cluster" {}

# Represents the cluster being "ready" – satisfied immediately for BYOK since
# the cluster is pre-existing.
output "cluster" {
  value = null_resource.cluster.id
}

output "ready" {
  value = null_resource.cluster.id
}

output "db_url" {
  value     = var.db_url
  sensitive = true
}

# No cloud IAM identity needed for BYOK.
output "identity" {
  value = ""
}

