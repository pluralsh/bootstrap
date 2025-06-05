resource "google_service_account" "externaldns" {
  account_id                   = "${var.cluster}-externaldns"
  display_name                 = substr("GCP SA bound to K8S SA ${local.project_id}[external-dns]", 0, 100)
  description                  = "GCP SA bound to K8S SA ${local.project_id}[external-dns]"
  project                      = local.project_id
  create_ignore_already_exists = true
}

resource "google_service_account_iam_member" "externaldns_workload_identity" {
  service_account_id = google_service_account.externaldns.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[external-dns/external-dns]"
}

resource "google_service_account_iam_member" "cert_manager_workload_identity" {
  service_account_id = google_service_account.externaldns.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${local.project_id}.svc.id.goog[cert-manager/cert-manager]"
}

resource "google_project_iam_member" "workload_identity_sa_bindings" {
  for_each = toset(["roles/dns.admin"])

  project = local.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.externaldns.email}"
}