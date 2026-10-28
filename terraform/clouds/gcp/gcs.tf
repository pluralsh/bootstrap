locals {
  console_object_store_bucket_name = lower(substr(replace("${var.cluster_name}-console-${var.project_id}", "_", "-"), 0, 63))
}

resource "google_storage_bucket" "console" {
  name                        = local.console_object_store_bucket_name
  project                     = var.project_id
  location                    = var.region
  force_destroy               = !var.deletion_protection
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  depends_on = [google_project_service.storage]
}

# Dedicated WI for the console KSA (plrl-console/console). Do not reuse
# module.console-workload-identity — that binds stacks in plrl-deploy-operator
# with roles/owner.
module "console-object-store-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name                = "${var.cluster_name}-plrl-console"
  namespace           = "plrl-console"
  project_id          = var.project_id
  use_existing_k8s_sa = true
  annotate_k8s_sa     = false
  k8s_sa_name         = "console"
  # Bucket-scoped IAM below; avoid project-wide storage roles.
  roles               = []
}

resource "google_storage_bucket_iam_member" "console_object_admin" {
  bucket = google_storage_bucket.console.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.console-object-store-workload-identity.gcp_service_account_email}"
}

resource "google_storage_bucket_iam_member" "console_legacy_bucket_reader" {
  bucket = google_storage_bucket.console.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${module.console-object-store-workload-identity.gcp_service_account_email}"
}
