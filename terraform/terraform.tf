# Since the versions of the module’s callers may differ, the version constraints should be loosened.
# See: https://developer.hashicorp.com/terraform/language/providers/requirements#best-practices-for-provider-versions
terraform {
  required_version = "1.12.1"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.28.0"
    }
  }
  backend "gcs" {
    bucket = "ctf-terraform-tfstate"
    prefix = "datadog-sandbox"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}