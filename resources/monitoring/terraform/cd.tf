locals {
  #context  = yamldecode(data.local_sensitive_file.context.content)
  repo_url = "https://github.com/pluralsh/bootstrap.git"
}

#data "local_sensitive_file" "context" {
#  filename = "${path.module}/../../context.yaml"
#}

data "plural_cluster" "mgmt" {
  handle = "mgmt"
}

// create the kubernetes namespace manually here so it can be used elsewhere w/in terraform w/o race conditions
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "plural_git_repository" "monitoring" {
  url     = local.repo_url
  decrypt = false
}

resource "plural_service_deployment" "monitoring-helm-repositories" {
  name      = "monitoring-helm-repositories"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  repository = {
    id     = plural_git_repository.monitoring.id
    ref    = "main"
    folder = "resources/monitoring/helm-repositories"
  }
  cluster = {
    id = data.plural_cluster.mgmt.id
  }
  configuration = {
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  protect = false

  depends_on = [kubernetes_namespace.monitoring]
}

resource "plural_service_deployment" "monitoring" {
  name      = "monitoring"
  namespace = kubernetes_namespace.monitoring.metadata[0].name
  repository = {
    id     = plural_git_repository.monitoring.id
    ref    = "main"
    folder = "resources/monitoring/services"
  }
  cluster = {
    id = data.plural_cluster.mgmt.id
  }

  protect = false

  depends_on = [kubernetes_namespace.monitoring]
  configuration = {
    monitoringRepo = plural_git_repository.monitoring.id
    repoUrl        = local.repo_url
    namespace      = kubernetes_namespace.monitoring.metadata[0].name
  }

  lifecycle {
    ignore_changes = [
      configuration["basicAuthPassword"],
      configuration["basicAuthUser"],
      configuration["basicAuthHtpasswd"],
    ]
  }
}

