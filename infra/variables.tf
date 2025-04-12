#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------

locals {
  common_tags = {
    terraform               = "true"
    environment             = "test"
    owner                   = "xxx"
    deperatment             = "salesengineering"
    location                = "tokyo"
    please_keep_my_resource = true
  }
  common_name = "ctf-infra"
}

#------------------------------------------------------------------------------
# Terrafrom variables
#------------------------------------------------------------------------------

variable "project_id" {
  description = "The ID for your GCP project"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-northeast1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "asia-northeast1-a"
}

variable "allowed_ip1" {
  description = "Allowed CIDR. This is the IP address of your office or home."
  type        = string
}

variable "allowed_ip2" {
  description = "Allowed CIDR. This is the IP address of your office or home."
  type        = string
}

variable "sa_email" {
  description = "Service account email"
  type        = string
  default     = "xxx@xxx.iam.gserviceaccount.com"
}

variable "machine_type" {
  description = "Machine type for the bastion host"
  type        = string
  default     = "e2-standard-2"
}

variable "dd_api_key" {
  description = "Datadog API Key"
  type        = string
}

variable "gke_release_channel" {
  description = "GKE cluster release channel."
  type        = string
  default     = "REGULAR" # "RAPID", "REGULAR", "STABLE"から選択
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