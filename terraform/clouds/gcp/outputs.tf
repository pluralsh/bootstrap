output "cluster" {
    value = module.gke
}

output "network" {
    value = module.gcp-network
}

output "db" {
    value = module.pg
}

output "db_url" {
    value = local.db_url
    sensitive = true
}

output "ready" {
    value = module.gke
}

output "identity" {
  value = module.console-workload-identity.gcp_service_account_email
}

output "console_gcs_bucket" {
  value = google_storage_bucket.console.name
}

output "console_gcs_project" {
  value = var.project_id
}

output "console_gcs_service_account" {
  value = module.console-object-store-workload-identity.gcp_service_account_email
}
