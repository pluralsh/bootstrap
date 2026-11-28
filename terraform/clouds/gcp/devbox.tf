# Plural devboxes: a node pool for Agent Substrate's gVisor workers, the bucket Substrate keeps actor snapshots in,
# and the Workload Identity service accounts that reach it. Devbox homes are Persistent Disks in the pool's zone. The
# services in bootstrap/devbox install Substrate and the DevboxRunner on top.

variable "devbox_enabled" {
  type    = bool
  default = true
}

variable "devbox_machine_type" {
  type    = string
  default = "n2-standard-8"
}

# gVisor snapshots need a single CPU model across the pool, so it runs in one zone on one CPU platform.
variable "devbox_min_cpu_platform" {
  type    = string
  default = "Intel Ice Lake"
}

variable "devbox_max_nodes" {
  type    = number
  default = 5
}

variable "devbox_boot_disk_size" {
  type        = number
  default     = 250
  description = "size in GiB of the boot disk, which also holds /var/lib/ate"
}

locals {
  devbox = var.devbox_enabled ? 1 : 0
  # Service account ids are 6-30 characters, so the cluster part is capped.
  devbox_suffix = trim(substr(replace(lower(var.cluster_name), "/[^a-z0-9-]/", "-"), 0, 18), "-")
  devbox_bucket_members = var.devbox_enabled ? {
    api      = google_service_account.devbox_api_server[0].email
    transfer = google_service_account.devbox_transfer[0].email
  } : {}
}

data "google_compute_zones" "devbox" {
  project = var.project_id
  region  = var.region
}

resource "google_container_node_pool" "devbox" {
  count              = local.devbox
  name               = "devbox"
  project            = var.project_id
  location           = var.region
  cluster            = module.gke.name
  node_locations     = [data.google_compute_zones.devbox.names[0]]
  initial_node_count = 0

  autoscaling {
    total_min_node_count = 0
    total_max_node_count = var.devbox_max_nodes
    location_policy      = "ANY"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type     = var.devbox_machine_type
    min_cpu_platform = var.devbox_min_cpu_platform
    image_type       = "UBUNTU_CONTAINERD"
    disk_size_gb     = var.devbox_boot_disk_size
    disk_type        = "pd-balanced"
    service_account  = module.gke.service_account
    oauth_scopes     = ["https://www.googleapis.com/auth/cloud-platform"]

    labels = {
      "plural.sh/devbox-pool" = "devbox"
    }

    taint {
      key    = "ate.dev/sandboxClass"
      value  = "gvisor"
      effect = "NO_SCHEDULE"
    }

    # lifted by devbox-disk-prep; /var/lib/ate stays on the boot disk, so there's nothing to format
    taint {
      key    = "plural.sh/devbox-disk"
      value  = "pending"
      effect = "NO_SCHEDULE"
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot = true
    }
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }
}

resource "google_storage_bucket" "devbox" {
  count                       = local.devbox
  project                     = var.project_id
  name                        = trim(substr("${var.project_id}-${local.devbox_suffix}-ate", 0, 63), "-")
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  # snapshots only outlive their devboxes, which go with the cluster
  force_destroy = true
}

resource "google_service_account" "devbox_api_server" {
  count        = local.devbox
  project      = var.project_id
  account_id   = "ate-api-${local.devbox_suffix}"
  display_name = "Agent Substrate ate-api-server on ${var.cluster_name}"
}

# ate-api-server impersonates this account for every snapshot transfer, with credentials scoped to one actor, so
# atelet itself needs no access to the bucket.
resource "google_service_account" "devbox_transfer" {
  count        = local.devbox
  project      = var.project_id
  account_id   = "ate-xfer-${local.devbox_suffix}"
  display_name = "Agent Substrate snapshot transfers on ${var.cluster_name}"
}

resource "google_service_account_iam_member" "devbox_api_server_workload_identity" {
  count              = local.devbox
  service_account_id = google_service_account.devbox_api_server[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[ate-system/ate-api-server]"
}

resource "google_service_account_iam_member" "devbox_transfer_token_creator" {
  count              = local.devbox
  service_account_id = google_service_account.devbox_transfer[0].name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.devbox_api_server[0].email}"
}

resource "google_storage_bucket_iam_member" "devbox" {
  for_each = var.devbox_enabled ? {
    "api-object-admin"       = { role = "roles/storage.objectAdmin", sa = "api" }
    "api-bucket-viewer"      = { role = "roles/storage.bucketViewer", sa = "api" }
    "transfer-object-admin"  = { role = "roles/storage.objectAdmin", sa = "transfer" }
    "transfer-bucket-viewer" = { role = "roles/storage.bucketViewer", sa = "transfer" }
  } : {}
  bucket = google_storage_bucket.devbox[0].name
  role   = each.value.role
  member = "serviceAccount:${local.devbox_bucket_members[each.value.sa]}"
}

output "devbox_snapshot_location" {
  value = try("gs://${google_storage_bucket.devbox[0].name}/substrate/", "")
}

output "devbox_api_server_service_account" {
  value = try(google_service_account.devbox_api_server[0].email, "")
}

output "devbox_transfer_service_account" {
  value = try(google_service_account.devbox_transfer[0].email, "")
}
