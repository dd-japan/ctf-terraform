#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------

locals {
  common_tags = {
    terraform               = "true"
    environment             = "test"
    owner                   = "dd-japan"
    deperatment             = "salesengineering"
    location                = "tokyo"
    please_keep_my_resource = true
  }

  common_name = "ctf-japan-master"
}

# Project variables
variable "project_id" {
  type    = string
  default = "datadog-sandbox"
}

variable "region" {
  type    = string
  default = "asia-northeast1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "asia-northeast1-a"
}

variable "allowed_ips" {
  description = "Allowed CIDR. This is the IP address of your office or home."
  type        = list(string)
  sensitive   = true
}

variable "machine_type" {
  description = "Machine type for the bastion host"
  type        = string
  default     = "e2-standard-2"
}

variable "dd_api_key" {
  description = "Datadog API Key"
  type        = string
  sensitive   = true
}

variable "gke_release_channel" {
  description = "GKE cluster release channel."
  type        = string
  default     = "REGULAR" # Choose from "RAPID", "REGULAR", "STABLE"
}

variable "gke_node_type" {
  description = "GKE node pool machine type."
  type        = string
  default     = "e2-medium"
}

variable "zones" {
  description = "Zone list to deploy GKE"
  type        = string
  default     = "asia-northeast1-a,asia-northeast1-b,asia-northeast1-c"
}

#------------------------------------------------------------------------------
# GitHub Container Registry Authentication
#------------------------------------------------------------------------------

variable "github_username" {
  description = "GitHub username for GHCR authentication"
  type        = string
  sensitive   = true
}

variable "github_email" {
  description = "GitHub email for GHCR authentication"
  type        = string
  sensitive   = true
}

variable "ghcr_access_token" {
  description = "GitHub Personal Access Token for GHCR authentication"
  type        = string
  sensitive   = true
}
