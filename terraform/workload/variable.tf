variable "project_id" {
  type        = string
  description = "value of project_id"
}

variable "enabled_services" {
  type = map(list(object({
    log_type         = string
    exempted_members = optional(list(string))
  })))
  description = "value of enabled_services"

  default = {
    "storage.googleapis.com" = [
      {
        log_type = "DATA_READ"
        # if you want to exempt some members from logging 
        # exempted_members = ["user:example.com", "serviceAccount:example.com]
      },
      {
        log_type = "DATA_WRITE"
      },
      {
        log_type = "ADMIN_READ"
      }
    ]
  }
}
