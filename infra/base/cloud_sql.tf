# Cloud SQL Instance: ctfd-japan (MySQL)
resource "google_sql_database_instance" "ctfd_japan" {
  name             = var.ctfd_instance_name
  database_version = var.ctfd_database_version
  region          = var.region
  project         = var.project_id

  settings {
    tier                        = var.ctfd_instance_tier
    availability_type          = var.ctfd_availability_type
    disk_size                  = var.ctfd_disk_size
    disk_type                  = var.ctfd_disk_type
    disk_autoresize           = true
    disk_autoresize_limit     = 0
    edition                   = var.ctfd_edition
    deletion_protection_enabled = true

    backup_configuration {
      enabled                        = true
      start_time                    = var.ctfd_backup_start_time
      backup_retention_settings {
        retained_backups = var.ctfd_backup_retention_count
        retention_unit   = "COUNT"
      }
      binary_log_enabled            = true
      transaction_log_retention_days = 14
      location                      = var.ctfd_backup_location
    }

    ip_configuration {
      ipv4_enabled = true
      ssl_mode     = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    }

    location_preference {
      zone = var.ctfd_zone
    }

    maintenance_window {
      day          = var.ctfd_maintenance_window_day
      hour         = var.ctfd_maintenance_window_hour
      update_track = var.ctfd_maintenance_update_track
    }

    data_cache_config {
      data_cache_enabled = true
    }

    insights_config {
      query_insights_enabled  = true
      query_plans_per_minute  = 5
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }
  }

  deletion_protection = true

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    google_project_service.sqladmin
  ]
}

# Database for ctfd-japan instance
resource "google_sql_database" "ctfd" {
  name      = var.ctfd_database_name
  instance  = google_sql_database_instance.ctfd_japan.name
  charset   = var.ctfd_database_charset
  collation = var.ctfd_database_collation
  project   = var.project_id
}

# User for ctfd-japan instance
resource "google_sql_user" "ctfduser" {
  name     = var.ctfd_database_user
  instance = google_sql_database_instance.ctfd_japan.name
  host     = "%"
  project  = var.project_id
  
  # Password should be managed externally or via sensitive variables
  password = var.ctfd_user_password
}

# Enable SQL Admin API
resource "google_project_service" "sqladmin" {
  project = var.project_id
  service = "sqladmin.googleapis.com"
}

# Enable Compute Engine API (required for VPC)
resource "google_project_service" "compute" {
  project = var.project_id
  service = "compute.googleapis.com"
}

# Outputs for CTFD Japan MySQL
output "ctfd_japan_connection_name" {
  description = "The connection name of the CTFD Japan Cloud SQL instance"
  value       = google_sql_database_instance.ctfd_japan.connection_name
}

output "ctfd_japan_public_ip" {
  description = "The public IP address of the CTFD Japan Cloud SQL instance"
  value       = google_sql_database_instance.ctfd_japan.public_ip_address
}

output "ctfd_japan_self_link" {
  description = "The URI of the CTFD Japan Cloud SQL instance"
  value       = google_sql_database_instance.ctfd_japan.self_link
}

output "ctfd_japan_service_account_email" {
  description = "The service account email address assigned to the CTFD Japan instance"
  value       = google_sql_database_instance.ctfd_japan.service_account_email_address
}

output "ctfd_database_name" {
  description = "The name of the CTFD database"
  value       = google_sql_database.ctfd.name
}

output "ctfd_user_name" {
  description = "The name of the CTFD user"
  value       = google_sql_user.ctfduser.name
} 