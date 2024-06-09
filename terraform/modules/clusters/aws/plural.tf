data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name

  depends_on = [ module.eks ]
}

resource "plural_cluster" "this" {
    handle = var.cluster
    name   = var.cluster
    tags   = {
        fleet = var.fleet
        tier = var.tier
    }

    metadata = jsonencode({
        iam = {
          load_balancer = module.addons.gitops_metadata.aws_load_balancer_controller_iam_role_arn
          cluster_autoscaler = module.addons.gitops_metadata.cluster_autoscaler_iam_role_arn
        }
    })

    kubeconfig = {
      host                   = module.eks.cluster_endpoint
      cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
      token                  = data.aws_eks_cluster_auth.cluster.token
    }

    depends_on = [ module.vpc ]
}