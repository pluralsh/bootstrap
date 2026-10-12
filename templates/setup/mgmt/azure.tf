resource "plural_cluster" "mgmt" {
    handle = "mgmt"
    name   = "[[ .CloudCluster ]]"

    depends_on = [ module.mgmt ]
}

output "identity" {
  value = module.mgmt.identity 
}