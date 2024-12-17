data "aws_eks_cluster" "mgmt" {
  name = var.cluster_name
}

data "aws_vpc" "mgmt" {
  id = one(data.aws_eks_cluster.mgmt.vpc_config).vpc_id
}

resource "plural_service_context" "mgmt" {
    name = "plrl/clusters/mgmt"
    configuration = {
        cluster_name = var.cluster_name
        vpc_id       = one(data.aws_eks_cluster.mgmt.vpc_config).vpc_id
        subnet_ids   = one(data.aws_eks_cluster.mgmt.vpc_config).subnet_ids
        vpc_cidr     = data.aws_vpc.mgmt.cidr_block
    }
}