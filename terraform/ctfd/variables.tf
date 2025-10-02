#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------

locals {
  common_tags = {
    terraform               = "true"
    deperatment             = "salesengineering"
    please_keep_my_resource = true
  }
}

variable "common_name" {
  type    = string
  default = "ctf-japan-master" # change to your name
}

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

#------------------------------------------------------------------------------
# Cloud SQL CTFD Japan MySQL variables
#------------------------------------------------------------------------------

variable "ctfd_database_version" {
  type        = string
  description = "The MySQL version for the CTFD Japan Cloud SQL instance"
  default     = "MYSQL_8_0_40"
}

variable "ctfd_instance_tier" {
  type        = string
  description = "The machine type for the CTFD Japan Cloud SQL instance"
  default     = "db-perf-optimized-N-8"
}

variable "ctfd_disk_size" {
  type        = number
  description = "The disk size in GB for the CTFD Japan Cloud SQL instance"
  default     = 250
}

variable "ctfd_disk_type" {
  type        = string
  description = "The disk type for the CTFD Japan Cloud SQL instance"
  default     = "PD_SSD"
}

variable "ctfd_availability_type" {
  type        = string
  description = "The availability type for the CTFD Japan Cloud SQL instance"
  default     = "REGIONAL"
}

variable "ctfd_edition" {
  type        = string
  description = "The edition of the CTFD Japan Cloud SQL instance"
  default     = "ENTERPRISE_PLUS"
}

variable "ctfd_zone" {
  type        = string
  description = "The GCP zone for the CTFD Japan Cloud SQL instance"
  default     = "asia-northeast1-b"
}

# Database configuration for CTFD Japan
variable "ctfd_database_name" {
  type        = string
  description = "The name of the CTFD database"
  default     = "ctfd"
}

variable "ctfd_database_charset" {
  type        = string
  description = "The charset for the CTFD database"
  default     = "utf8mb4"
}

variable "ctfd_database_collation" {
  type        = string
  description = "The collation for the CTFD database"
  default     = "utf8mb4_0900_ai_ci"
}

# User configuration for CTFD Japan
variable "ctfd_database_user" {
  type        = string
  description = "The CTFD database user name"
  default     = "ctfduser"
}

variable "ctfd_user_password" {
  type        = string
  description = "Password for the CTFD user"
  sensitive   = true
  default     = "changeme123456789!"
}

# CTFd Secret Key
variable "ctfd_secret_key" {
  type        = string
  description = "Secret key for CTFd application"
  sensitive   = true
  default     = "changeme123456789!"
}

# Organization ID for tags
variable "parent_tag_key" {
  type        = string
  description = "Organization ID for Google Cloud tags"
  default     = "281480928926413"
}