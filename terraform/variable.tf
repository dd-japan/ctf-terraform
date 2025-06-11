#------------------------------------------------------------------------------
# Workload Identity Poolに関するvariable
#------------------------------------------------------------------------------
# Projectに関するvariable
variable "project_id" {
  type    = string
  default = "datadog-sandbox"
}

# 環境に関するvariable
variable "env" {
  type    = string
  default = "dev"
}

variable "github_org" {
  type    = string
  default = "dd-japan"
}

variable "repo_name" {
  type    = string
  default = "ctf-terraform"
}

# backendに関するvariable
variable "tfstate_bucket_name" {
  type    = string
  default = "ctf-terraform-tfstate"
}

variable "region" {
  type    = string
  default = "asia-northeast1"
}

variable "enabled_services" {
  type = map(list(object({
    log_type         = string
    exempted_members = optional(list(string))
  })))

  default = {
    "storage.googleapis.com" = [
      {
        log_type = "DATA_READ"
      },
      {
        log_type = "DATA_WRITE"
      },
      {
        log_type = "ADMIN_READ"
      }
    ],
  }
}

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
  common_name = "ctf-test"
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