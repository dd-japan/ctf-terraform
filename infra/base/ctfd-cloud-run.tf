#------------------------------------------------------------------------------
# GCS Bucket for CTFd Uploads
#------------------------------------------------------------------------------

resource "google_storage_bucket" "ctfd_uploads" {
  name          = "${var.project_id}-ctfd-uploads"
  location      = var.region
  force_destroy = true  # テスト環境用。本番環境ではfalseにすること

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
  account_id   = "ctfd-cloud-run"
  display_name = "CTFd Cloud Run Service Account"
  description  = "Service account for CTFd Cloud Run service"
  project      = var.project_id
}

# Cloud SQL Client権限
resource "google_project_iam_member" "ctfd_cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.ctfd_cloud_run.email}"
}

# GCS権限
resource "google_storage_bucket_iam_member" "ctfd_storage_access" {
  bucket = google_storage_bucket.ctfd_uploads.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.ctfd_cloud_run.email}"
}

#------------------------------------------------------------------------------
# Enable Required APIs
#------------------------------------------------------------------------------

resource "google_project_service" "run" {
  project = var.project_id
  service = "run.googleapis.com"
}

resource "google_project_service" "storage" {
  project = var.project_id
  service = "storage.googleapis.com"
}

#------------------------------------------------------------------------------
# Cloud Run Service for CTFd
#------------------------------------------------------------------------------

resource "google_cloud_run_service" "ctfd" {
  name     = "ctfd-single-container"
  location = var.region
  project  = var.project_id

  template {
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale"        = "1"
        "autoscaling.knative.dev/maxScale"        = "3"
        "run.googleapis.com/cpu-throttling"       = "false"
        "run.googleapis.com/startup-cpu-boost"    = "true"
        "run.googleapis.com/execution-environment" = "gen2"
        "run.googleapis.com/cloudsql-instances"   = "${var.project_id}:${var.region}:${var.ctfd_instance_name}"
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
          value = "mysql+pymysql://${var.ctfd_database_user}:${var.ctfd_user_password != null ? var.ctfd_user_password : "changeme"}@/${var.ctfd_database_name}?unix_socket=/cloudsql/${var.project_id}:${var.region}:${var.ctfd_instance_name}"
        }

        env {
          name  = "UPLOAD_FOLDER"
          value = "/var/uploads"
        }

        env {
          name  = "REVERSE_PROXY"
          value = "true"
        }

        # CTFdの設定環境変数
        env {
          name  = "SECRET_KEY"
          value = var.ctfd_secret_key != null ? var.ctfd_secret_key : "changeme-secret-key"
        }

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

        # ヘルスチェック設定
        startup_probe {
          http_get {
            path = "/healthcheck"
            port = 8000
          }
          initial_delay_seconds = 30
          timeout_seconds      = 10
          period_seconds       = 10
          failure_threshold    = 3
        }

        liveness_probe {
          http_get {
            path = "/healthcheck"
            port = 8000
          }
          initial_delay_seconds = 60
          timeout_seconds      = 10
          period_seconds       = 30
          failure_threshold    = 3
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
    google_sql_database_instance.ctfd_japan,
    google_storage_bucket.ctfd_uploads,
    google_project_service.run,
    google_project_service.storage
  ]
}

#------------------------------------------------------------------------------
# IAM for Cloud Run Public Access
#------------------------------------------------------------------------------

resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_service.ctfd.location
  service  = google_cloud_run_service.ctfd.name
  role     = "roles/run.invoker"
  member   = "allUsers"  # パブリックアクセスを許可。必要に応じて制限可能
}

#------------------------------------------------------------------------------
# Outputs
#------------------------------------------------------------------------------

output "ctfd_service_url" {
  description = "URL of the CTFd Cloud Run service"
  value       = google_cloud_run_service.ctfd.status[0].url
}

output "ctfd_uploads_bucket" {
  description = "Name of the CTFd uploads GCS bucket"
  value       = google_storage_bucket.ctfd_uploads.name
}

output "ctfd_service_account_email" {
  description = "Email of the CTFd Cloud Run service account"
  value       = google_service_account.ctfd_cloud_run.email
}