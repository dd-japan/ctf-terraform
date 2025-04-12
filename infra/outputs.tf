#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------
/*
output "network" {
  description = "The created network"
  value       = module.vpc.network
}
*/
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
/*
output "subnets" {
  description = "A map with keys of form subnet_region/subnet_name and values being the outputs of the google_compute_subnetwork resources used to create corresponding subnets."
  value       = module.vpc.subnets
}
*/
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
# SSH key pair
#------------------------------------------------------------------------------

output "common_public_key_openssh" {
  description = "value of the public key in OpenSSH format"
  value       = tls_private_key.ctf_infra_common.public_key_openssh
}

output "common_private_key_openssh" {
  description = "value of the private key in OpenSSH format"
  value       = tls_private_key.ctf_infra_common.private_key_openssh
  sensitive   = true
}

#------------------------------------------------------------------------------
# Bastion
#------------------------------------------------------------------------------

output "bastion_global_ip" {
  description = "The public (global) IP of the bastion server"
  value       = google_compute_address.bastion.address
}

output "bastion_private_ip" {
  description = "The private IP of the bastion server"
  value       = google_compute_instance.bastion.network_interface.0.network_ip
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

#------------------------------------------------------------------------------
# Instruction
#------------------------------------------------------------------------------

output "instruction" {
  value = <<EOT
# 疎通を許可したいIPアドレス確認
curl ifconfig.me

# BastionホストへのSSH接続
ssh -i ~/ctf_infra_bastion_key -o IdentitiesOnly=yes ubuntu@${google_compute_address.bastion.address}

# Initializeの処理が終わるまで10分程度待つ
tail /var/log/user-data.log

# Datadogエージェントのステータス確認
kubectl exec -n default <datadog-agent-pod名> -c agent -- agent status

# (念の為)Terraformでリソースを削除する前に
kubectl delete -k /home/ubuntu/ctf-swagstore/kustomize/
kubectl -n default get all
  EOT
}