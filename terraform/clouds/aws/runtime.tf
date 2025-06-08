module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.21" #ensure to update this to the latest/desired version

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  eks_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
      configuration_values = jsonencode({
        defaultStorageClass = {
          enabled = true
        }
      })
    }
    coredns = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa_role.iam_role_arn
    }
    kube-proxy = {
      most_recent = true
    }
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  # mostly need this module to install the lb controller here.
  enable_aws_load_balancer_controller = true
  enable_cluster_autoscaler           = true
  enable_metrics_server               = true

  depends_on = [
    module.eks,
  ]
}

module "vpc_cni_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.55"

  role_name             = "${module.eks.cluster_name}-vpc-cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true
  vpc_cni_enable_ipv6   = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.55"

  role_name             = "${module.eks.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}
