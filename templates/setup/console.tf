// leave this resource static, if you want to modify console values, do it in the generated helm values directly instead.
resource "null_resource" "console" {
  provisioner "local-exec" {
    command     = "plural cd control-plane-values --name {{ .Cluster }} --dsn \"${module.mgmt.db_url}\" --domain {{ .Subdomain }} --file console.yaml --object-store-bucket \"${try(module.mgmt.console_s3_bucket, "")}\" --object-store-region \"${try(module.mgmt.console_s3_region, "")}\" --object-store-azure-storage-account \"${try(module.mgmt.console_azure_storage_account, "")}\" --object-store-azure-container \"${try(module.mgmt.console_azure_container, "")}\" --object-store-azure-client-id \"${try(module.mgmt.console_azure_client_id, "")}\" --object-store-gcs-bucket \"${try(module.mgmt.console_gcs_bucket, "")}\" --object-store-gcs-service-account \"${try(module.mgmt.console_gcs_service_account, "")}\""
    working_dir = "${path.module}/../../temp/helm"
  }
}

data "local_sensitive_file" "certmanager" {
  filename = "${path.module}/../../helm/certmanager.yaml"
}

data "local_sensitive_file" "flux" {
  filename = "${path.module}/../../helm/flux.yaml"
}

data "local_sensitive_file" "runtime" {
  filename = "${path.module}/../../temp/helm/runtime.yaml"
}

data "local_sensitive_file" "console" {
  filename   = "${path.module}/../../temp/helm/console.yaml"
  depends_on = [null_resource.console]
}

resource "helm_release" "certmanager" {
  name             = "cert-manager"
  namespace        = "cert-manager"
  chart            = "cert-manager"
  repository       = "https://charts.jetstack.io"
  version          = "v1.17.2"
  create_namespace = true
  timeout          = 300
  wait             = true
  values = [
    data.local_sensitive_file.certmanager.content
  ]

  depends_on = [module.mgmt.cluster, module.mgmt.ready]
}

resource "helm_release" "flux" {
  name             = "flux"
  namespace        = "flux"
  chart            = "flux2"
  repository       = "https://fluxcd-community.github.io/helm-charts"
  version          = "2.15.0"
  create_namespace = true
  timeout          = 300
  wait             = false
  values = [
    data.local_sensitive_file.flux.content
  ]

  depends_on = [module.mgmt.cluster]
}

resource "helm_release" "runtime" {
  name             = "runtime"
  namespace        = "plural-runtime"
  chart            = "runtime"
  repository       = "https://pluralsh.github.io/bootstrap"
  version          = "0.1.33"
  create_namespace = true
  timeout          = 300
  wait             = false
  values = [
    data.local_sensitive_file.runtime.content
  ]

  depends_on = [module.mgmt.cluster, helm_release.certmanager, helm_release.flux]
}

resource "helm_release" "console" {
  name             = "console"
  namespace        = "plrl-console"
  chart            = "console"
  repository       = "https://pluralsh.github.io/console"
  version          = "0.4.48"
  create_namespace = true
  timeout          = 600
  wait             = true
  values = [
    data.local_sensitive_file.console.content
  ]

  depends_on = [module.mgmt.cluster, helm_release.runtime, module.mgmt.db_url]
}

output "identity" {
  value = module.mgmt.identity
}
