locals {
    kubeconfig = yamldecode(base64decode(linode_lke_cluster.cluster.kubeconfig))
    cluster = local.kubeconfig.clusters[0].cluster
    user = local.kubeconfig.users[0].user
}

resource "plural_cluster" "this" {
  handle = var.cluster
  name   = var.cluster

  tags = {
    tier  = var.tier
    fleet = var.fleet
  }

  kubeconfig = {
    host = local.cluster.server
    cluster_ca_certificate = base64decode(local.cluster["certificate-authority-data"])
    token = local.user.token
  }
}