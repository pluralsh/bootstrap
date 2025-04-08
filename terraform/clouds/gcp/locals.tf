locals {
  db_name    = var.db_name == "" ? "${var.cluster_name}-plural-db" : var.db_name
  range_name = var.allocated_range_name == "" ? "${var.cluster_name}-managed-services" : var.allocated_range_name
  db_url = format("postgresql://console:%s@%s:5432/console", random_password.password.result, try(module.pg[0].private_ip_address, ""))
  network_name = format("%s-%s", var.cluster_name, var.network)
}