#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------

output "network_id" {
  description = "The ID of the VPC being created"
  value       = module.vpc.network_id
}

output "network_name" {
  description = "The name of the VPC being created"
  value       = module.vpc.network_name
}

output "network_self_link" {
  description = "The URI of the VPC being created"
  value       = module.vpc.network_self_link
}

output "subnets_ids" {
  description = "The IDs of the subnets being created"
  value       = module.vpc.subnets_ids
}

output "subnets_ips" {
  description = "The IPs and CIDRs of the subnets being created"
  value       = module.vpc.subnets_ips
}

output "subnets_self_links" {
  description = "The self-links of subnets being created"
  value       = module.vpc.subnets_self_links
}

#------------------------------------------------------------------------------
# GKE
#------------------------------------------------------------------------------

output "gke_cluster_name" {
  description = "GKE cluster name."
  value       = module.gke.name
}

output "gke_endpoint" {
  description = "The endpoint of this cluster's Kubernetes master."
  value       = module.gke.endpoint
}

output "gke_ca_certificate" {
  description = "The base64 encoded CA certificate used to connect to this cluster's Kubernetes master."
  value       = module.gke.ca_certificate
}

output "dd_apikey_secret_name" {
  value       = kubernetes_secret.datadog_api.metadata[0].name
  description = "The name of the secret containing the Datadog API key."
}

#------------------------------------------------------------------------------
# CTFD Japan MySQL
#------------------------------------------------------------------------------

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

#------------------------------------------------------------------------------
# CTFd Cloud Run
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

#------------------------------------------------------------------------------
# Instruction
#------------------------------------------------------------------------------

output "instruction" {
  value = <<EOT
gcloud auth login
gcloud container clusters get-credentials ${module.gke.name} --region ${var.region} --project ${var.project_id}

kubectl api-resources |grep datadog
  EOT
}