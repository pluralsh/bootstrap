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
        role = "workload"
    }

    metadata = jsonencode({
        tier = var.tier
        dns_zone = try(local.vpc.ingress_dns_zone, "example.com")
        iam = {
          load_balancer = module.addons.gitops_metadata.aws_load_balancer_controller_iam_role_arn
          cluster_autoscaler = module.addons.gitops_metadata.cluster_autoscaler_iam_role_arn
          external_dns = module.externaldns_irsa_role.iam_role_arn
          cert_manager = module.externaldns_irsa_role.iam_role_arn
        }

        vpc_id = local.vpc.vpc_id
        
        network = {
          private_subnets = local.vpc.private_subnets
          public_subnets  = local.vpc.public_subnets
        }
    })

    kubeconfig = {
      host                   = module.eks.cluster_endpoint
      cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
      token                  = data.aws_eks_cluster_auth.cluster.token
    }

    depends_on = [ 
      module.addons,
      module.ebs_csi_irsa_role, 
      module.vpc_cni_irsa_role, 
      module.externaldns_irsa_role 
    ]
}