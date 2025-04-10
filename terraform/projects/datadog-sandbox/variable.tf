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
