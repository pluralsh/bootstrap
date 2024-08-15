resource "plural_cluster" "mgmt" {
    handle = "mgmt"
    name   = "[[ .Cluster ]]"
    
    kubeconfig = {
      host                   = module.mgmt.cluster_endpoint
      cluster_ca_certificate = base64decode(module.mgmt.cluster_certificate_authority_data)
      token                  = data.aws_eks_cluster_auth.cluster.token
    }

    depends_on = [ module.mgmt ]
}