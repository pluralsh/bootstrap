resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1
  special     = false
}

module "pg" {
  count = var.create_db ? 1 : 0
  source  = "terraform-google-modules/sql-db/google//modules/postgresql"
  version = "~> 25.2"

  name                 = local.db_name
  random_instance_name = false
  project_id           = var.project_id
  database_version     = "POSTGRES_14"
  region               = var.region

  // Master configurations
  tier                            = var.db_size
  availability_type               = "REGIONAL"
  maintenance_window_day          = 7
  maintenance_window_hour         = 12
  maintenance_window_update_track = "stable"

  deletion_protection = var.deletion_protection

  database_flags = [{ name = "autovacuum", value = "on" }]

  insights_config = {
    query_plans_per_minute = 5
  }

  ip_configuration = {
    ipv4_enabled                  = true
    private_network               = module.gcp-network.network_id
    psc_enabled                   = false
    require_ssl                   = false
    allocated_ip_range            = google_compute_global_address.private_ip_alloc[0].name
    ssl_mode                      = "ENCRYPTED_ONLY"
  }

  backup_configuration = {
    enabled                        = true
    start_time                     = "20:55"
    location                       = null
    point_in_time_recovery_enabled = true
    transaction_log_retention_days = 7
    retained_backups               = 365
    retention_unit                 = "COUNT"
  }

  db_name      = "console"
  db_charset   = "UTF8"
  db_collation = "en_US.UTF8"

  user_name     = "console"
  user_password = random_password.password.result

  depends_on = [ 
    google_project_service.sql,
    google_project_service.servicenetworking,
    google_service_networking_connection.postgres
  ]
}
