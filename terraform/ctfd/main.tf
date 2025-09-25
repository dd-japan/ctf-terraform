data "google_client_config" "default" {}

resource "random_pet" "ctfd" {
  length = 1
}

#------------------------------------------------------------------------------
# Cloud SQL Instance: ctfd-japan (MySQL)
#------------------------------------------------------------------------------

resource "google_sql_database_instance" "ctfd" {
  name             = "${local.common_name}-${random_pet.ctfd.id}"
  database_version = var.ctfd_database_version
  region           = var.region
  project          = var.project_id

  settings {
    tier                        = var.ctfd_instance_tier
    availability_type           = var.ctfd_availability_type
    disk_size                   = var.ctfd_disk_size
    disk_type                   = var.ctfd_disk_type
    disk_autoresize             = true
    disk_autoresize_limit       = 0
    edition                     = var.ctfd_edition
    deletion_protection_enabled = false

    ip_configuration {
      ipv4_enabled = true
      ssl_mode     = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    }

    location_preference {
      zone = var.ctfd_zone
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

  deletion_protection = false
}

# Database for ctfd-japan instance
resource "google_sql_database" "ctfd" {
  name      = "${local.common_name}-${random_pet.ctfd.id}"
  instance  = google_sql_database_instance.ctfd.name
  charset   = var.ctfd_database_charset
  collation = var.ctfd_database_collation
  project   = var.project_id
}

# User for ctfd-japan instance
resource "google_sql_user" "ctfduser" {
  name     = var.ctfd_database_user
  instance = google_sql_database_instance.ctfd.name
  host     = "%"
  project  = var.project_id

  # Password should be managed externally or via sensitive variables
  password = var.ctfd_user_password
}

#------------------------------------------------------------------------------
# GCS Bucket for CTFd Uploads
#------------------------------------------------------------------------------

resource "google_storage_bucket" "ctfd_uploads" {
  name          = "${local.common_name}-${random_pet.ctfd.id}"
  location      = var.region
  force_destroy = true # For test environment. Set to false for production
  project       = var.project_id

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }
}

#------------------------------------------------------------------------------
# Cloud Run Service Account
#------------------------------------------------------------------------------

resource "google_service_account" "ctfd_cloud_run" {
  account_id   = "${local.common_name}-cloud-run"
  display_name = "CTFd Cloud Run Service Account"
  description  = "Service account for CTFd Cloud Run service"
  project      = var.project_id
}

# Cloud SQL Client permissions
resource "google_project_iam_binding" "ctfd_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  members = ["serviceAccount:${google_service_account.ctfd_cloud_run.email}"]
}

# GCS permissions
resource "google_storage_bucket_iam_member" "ctfd_storage_access" {
  bucket = google_storage_bucket.ctfd_uploads.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.ctfd_cloud_run.email}"
}

#------------------------------------------------------------------------------
# Cloud Run Service for CTFd
#------------------------------------------------------------------------------

resource "google_cloud_run_service" "ctfd" {
  name     = "${local.common_name}-${random_pet.ctfd.id}-ctfd-single-container"
  location = var.region
  project  = var.project_id

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"         = "1"
        "autoscaling.knative.dev/maxScale"         = "3"
        "run.googleapis.com/cpu-throttling"        = "false"
        "run.googleapis.com/startup-cpu-boost"     = "true"
        "run.googleapis.com/execution-environment" = "gen2"
        "run.googleapis.com/cloudsql-instances"    = "${var.project_id}:${var.region}:${google_sql_database_instance.ctfd.name}"
      }
    }

    spec {
      service_account_name = google_service_account.ctfd_cloud_run.email

      containers {
        name  = "ctfd"
        image = "ctfd/ctfd:latest"

        ports {
          container_port = 8000
        }

        env {
          name  = "DATABASE_URL"
          value = "mysql+pymysql://${var.ctfd_database_user}:${var.ctfd_user_password != null ? var.ctfd_user_password : "changeme"}@/${var.ctfd_database_name}?unix_socket=/cloudsql/${var.project_id}:${var.region}:${google_sql_database_instance.ctfd.name}"
        }

        env {
          name  = "UPLOAD_FOLDER"
          value = "/var/uploads"
        }

        env {
          name  = "REVERSE_PROXY"
          value = "true"
        }

        env {
          name  = "SECRET_KEY"
          value = var.ctfd_secret_key
        }


        startup_probe {
          http_get {
            path = "/"
            port = 8000
          }
          initial_delay_seconds = 30
          period_seconds        = 10
          timeout_seconds       = 5
          failure_threshold     = 6
        }

        liveness_probe {
          http_get {
            path = "/"
            port = 8000
          }
          initial_delay_seconds = 60
          period_seconds        = 30
          timeout_seconds       = 5
          failure_threshold     = 3
        }

        # CTFd configuration environment variables

        env {
          name  = "WORKERS"
          value = "1"
        }

        volume_mounts {
          name       = "uploads-volume"
          mount_path = "/var/uploads"
        }

        resources {
          limits = {
            cpu    = "2"
            memory = "2Gi"
          }
          requests = {
            cpu    = "1"
            memory = "1Gi"
          }
        }

      }

      volumes {
        name = "uploads-volume"
        csi {
          driver    = "gcsfuse.run.googleapis.com"
          read_only = false
          volume_attributes = {
            bucketName = google_storage_bucket.ctfd_uploads.name
          }
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    google_sql_database_instance.ctfd,
    google_storage_bucket.ctfd_uploads
  ]
}

data "google_tags_tag_value" "external_access_allowed" {
  short_name = "allowed"
  parent     = "tagKeys/281480928926413"
}

resource "google_tags_location_tag_binding" "ctfd_tag_binding" {
  parent    = "//run.googleapis.com/projects/${var.project_id}/locations/${var.region}/services/${google_cloud_run_service.ctfd.name}"
  tag_value = data.google_tags_tag_value.external_access_allowed.id
  location  = var.region
}