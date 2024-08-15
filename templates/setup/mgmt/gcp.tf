resource "plural_cluster" "mgmt" {
    handle = "mgmt"
    name   = "[[ .CloudCluster ]]"
    
    kubeconfig = {
      host                   = module.mgmt.cluster.endpoint
      cluster_ca_certificate = base64decode(module.mgmt.cluster.ca_certificate)
      token                  = data.google_client_config.default.access_token
    }

    depends_on = [ module.mgmt ]
}