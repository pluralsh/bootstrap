locals {
  db_name = var.db_name == "" ? "${var.cluster_name}-plural-db" : var.db_name
  db_url = format("postgresql://console:%s@%s:5432/console", random_password.password.result, coalesce(try(module.db.db_instance_address, ""), "ignore"))
  cluster_ready = {
    cluster = module.eks
    addons = module.eks_blueprints_addons
  }
  vpc_name = var.vpc_name == "" ? "${var.cluster_name}-vpc" : var.vpc_name
  monitoring_role_name = var.monitoring_role == "" ? "${var.cluster_name}-PluralRDSMonitoringRole" : var.monitoring_role
  split_vsn = [ for i in split(".", var.next_kubernetes_version): tonumber(i) ]
  vsn_even = ((tonumber(local.split_vsn[0]) * 100 + tonumber(local.split_vsn[1])) % 2) == 0
  active_node_group = local.vsn_even ? "blue" : "green"
  drain_node_group = local.vsn_even ? "green" : "blue"
}