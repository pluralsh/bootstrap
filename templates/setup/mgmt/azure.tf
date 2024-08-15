resource "plural_cluster" "mgmt" {
    handle = "mgmt"
    name   = "[[ .CloudCluster ]]"
    
    kubeconfig = {
      host                   = module.mgmt.cluster.cluster_fqdn
      cluster_ca_certificate = base64decode(module.mgmt.cluster.cluster_ca_certificate)
      client_certificate     = base64decode(module.mgmt.cluster.client_certificate)
      client_key             = base64decode(module.mgmt.cluster.client_key)
    }

    depends_on = [ module.mgmt ]
}