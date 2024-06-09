module "console-workload-identity" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name       = "${var.cluster_name}-console"
  namespace  = "plrl-deploy-operator"
  project_id = var.project_id
  use_existing_k8s_sa = true
  annotate_k8s_sa = false
  k8s_sa_name = "stacks"
  roles = ["roles/owner", "roles/storage.admin"]
}