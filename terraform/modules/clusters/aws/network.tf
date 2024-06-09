data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.4"

  name                        = local.vpc_name
  cidr                        = var.vpc_cidr
  azs                         = data.aws_availability_zones.available.names
  public_subnets              = var.public_subnets
  private_subnets             = var.private_subnets
  enable_dns_hostnames        = true
  enable_ipv6                 = false
  public_subnet_enable_dns64  = false
  private_subnet_enable_dns64 = false

  enable_nat_gateway = true
  single_nat_gateway = false

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}
