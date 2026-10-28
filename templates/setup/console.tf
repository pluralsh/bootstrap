// leave this resource static, if you want to modify console values, do it in the generated helm values directly instead.
resource "null_resource" "console" {
  provisioner "local-exec" {
    command     = "plural cd control-plane-values --name {{ .Cluster }} --dsn \"${module.mgmt.db_url}\" --domain {{ .Subdomain }} --file console.yaml"
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

{{ if eq .Provider "aws" }}
locals {
  # NLBs send PROXY protocol v2 headers, trust them only from inside the VPC
  vpc_trusted_ips = {
    proxyProtocol = { trustedIPs = [module.mgmt.vpc.vpc_cidr_block] }
  }
  runtime_vpc_values = { for instance in ["traefik", "traefik-private"] : instance => {
    ports = { web = local.vpc_trusted_ips, websecure = local.vpc_trusted_ips }
  } }
}
{{ end }}
resource "helm_release" "runtime" {
  name             = "runtime"
  namespace        = "plural-runtime"
  chart            = "runtime"
  repository       = "https://pluralsh.github.io/bootstrap"
  version          = "1.0.0"
  create_namespace = true
  timeout          = 300
  wait             = false
  values = [
    data.local_sensitive_file.runtime.content,
{{- if eq .Provider "aws" }}
    yamlencode(local.runtime_vpc_values),
{{- end }}
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
