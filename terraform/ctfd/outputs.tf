#------------------------------------------------------------------------------
# CTFd Japan MySQL
#------------------------------------------------------------------------------

output "ctfd_japan_connection_name" {
  description = "The connection name of the CTFD Japan Cloud SQL instance"
  value       = google_sql_database_instance.ctfd.connection_name
}

output "ctfd_japan_public_ip" {
  description = "The public IP address of the CTFD Japan Cloud SQL instance"
  value       = google_sql_database_instance.ctfd.public_ip_address
}

output "ctfd_japan_self_link" {
  description = "The URI of the CTFD Japan Cloud SQL instance"
  value       = google_sql_database_instance.ctfd.self_link
}

output "ctfd_japan_service_account_email" {
  description = "The service account email address assigned to the CTFD Japan instance"
  value       = google_sql_database_instance.ctfd.service_account_email_address
}

output "ctfd_database_name" {
  description = "The name of the CTFD database"
  value       = google_sql_database.ctfd.name
}

output "ctfd_user_name" {
  description = "The name of the CTFD user"
  value       = google_sql_user.ctfduser.name
}

#------------------------------------------------------------------------------
# CTFd Cloud Run
#------------------------------------------------------------------------------

output "ctfd_service_id" {
  description = "ID of the CTFd Cloud Run service"
  value       = google_cloud_run_service.ctfd.id
}

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