locals {
  db_name    = var.db_name == "" ? "${var.cluster_name}-plural-db" : var.db_name
  range_name = var.allocated_range_name == "" ? "${var.cluster_name}-managed-services" : var.allocated_range_name
  db_url = format("postgresql://console:%s@%s:5432/console", random_password.password.result, try(module.pg[0].private_ip_address, ""))
  network_name = format("%s-%s", var.cluster_name, var.network)
  subnetwork_name = format("%s-%s", var.cluster_name, var.subnetwork)

  upgrading         = var.kubernetes_version != var.next_kubernetes_version
  split_vsn         = [for i in split(".", var.kubernetes_version) : tonumber(i)]
  vsn_even          = ((tonumber(local.split_vsn[0]) * 100 + tonumber(local.split_vsn[1])) % 2) == 0
  active_node_group = local.vsn_even ? "blue" : "green"
  drain_node_group  = local.vsn_even ? "green" : "blue"
}