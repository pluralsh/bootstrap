locals {
  context = yamldecode(data.local_sensitive_file.context.content)
  workspace = yamldecode(data.local_sensitive_file.workspace.content)
  branch = lookup(local.workspace.spec.context, "Branch", "main")
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
    private_key = try(local.context.spec.configuration.console.private_key, null)
    username    = try(local.context.spec.configuration.console.git_username, null)
    password    = try(local.context.spec.configuration.console.git_password, null)
    decrypt     = try(local.context.spec.configuration.console.private_key, null) != null
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
