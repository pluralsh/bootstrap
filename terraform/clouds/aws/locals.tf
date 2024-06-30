locals {
  db_name = var.db_name == "" ? "${var.cluster_name}-plural-db" : var.db_name
  db_url = format("postgresql://console:%s@%s:5432/console", random_password.password.result, coalesce(try(module.db.db_instance_address, ""), "ignore"))
  cluster_ready = {
    cluster = module.eks
    addons = module.eks_blueprints_addons
  }
  vpc_name = var.vpc_name == "" ? "${var.cluster_name}-vpc" : var.vpc_name
  monitoring_role_name = var.monitoring_role == "" ? "${var.cluster_name}-PluralRDSMonitoringRole" : var.monitoring_role
}