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
# Instruction
#------------------------------------------------------------------------------

output "instruction" {
  value = <<EOT
gcloud auth login
gcloud container clusters get-credentials ${module.gke.name} --region ${var.region} --project ${var.project_id}

kubectl api-resources |grep datadog
  EOT
}