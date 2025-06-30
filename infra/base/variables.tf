# 基本変数
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

##################################################################################
# Cloud SQL CTFD Japan MySQL に関するvariable
##################################################################################
variable "ctfd_instance_name" {
  type        = string
  description = "The name of the CTFD Japan Cloud SQL instance"
  default     = "ctfd-japan"
}

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
  default     = null
}

# Backup configuration for CTFD Japan
variable "ctfd_backup_start_time" {
  type        = string
  description = "The start time for automated backups for CTFD Japan"
  default     = "05:00"
}

variable "ctfd_backup_retention_count" {
  type        = number
  description = "The number of backups to retain for CTFD Japan"
  default     = 15
}

variable "ctfd_backup_location" {
  type        = string
  description = "The location for backups for CTFD Japan"
  default     = "asia"
}

# Maintenance window configuration for CTFD Japan
variable "ctfd_maintenance_window_day" {
  type        = number
  description = "The day of the week for maintenance for CTFD Japan (1 = Monday, 7 = Sunday)"
  default     = 7
}

variable "ctfd_maintenance_window_hour" {
  type        = number
  description = "The hour of the day for maintenance for CTFD Japan (UTC)"
  default     = 0
}

variable "ctfd_maintenance_update_track" {
  type        = string
  description = "The update track for maintenance for CTFD Japan"
  default     = "stable"
}

# CTFd Secret Key
variable "ctfd_secret_key" {
  type        = string
  description = "Secret key for CTFd application"
  sensitive   = true
  default     = null
}
################################################################################## 