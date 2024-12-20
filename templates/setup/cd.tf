locals {
  context = yamldecode(data.local_sensitive_file.context.content)
  workspace = yamldecode(data.local_sensitive_file.workspace.content)
  branch = local.workspace.spec.context.Branch == null ? "main" : local.workspace.spec.context.Branch
}

data "local_sensitive_file" "context" {
  filename = "${path.module}/../../context.yaml"
}

data "local_sensitive_file" "workspace" {
  filename = "${path.module}/../../workspace.yaml"
}

data "plural_cluster" "mgmt" {
    handle = "mgmt"
}

resource "plural_git_repository" "infra" {
    url         = local.context.spec.configuration.console.repo_url
    private_key = local.context.spec.configuration.console.private_key
    decrypt     = true
}

resource "plural_service_deployment" "apps" {
    name = "apps"
    namespace = "infra"
    repository = {
        id = plural_git_repository.infra.id
        ref = local.branch
        folder = "bootstrap"
    }
    cluster = {
        id = data.plural_cluster.mgmt.id
    }
    
    protect = true
    templated = true
}
