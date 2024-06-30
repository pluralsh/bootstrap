locals {
  network_name = "${var.fleet}-${var.cluster}-network"
  subnet_name = "${var.fleet}-${var.cluster}-subnetwork"
  range_name = var.allocated_range_name == "" ? "${var.cluster}-${var.fleet}-managed-services" : var.allocated_range_name
  
  # db_created = var.create_db ? module.pg.0.google_sql_user.default[0] : {}
}