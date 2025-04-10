# Since the versions of the module’s callers may differ, the version constraints should be loosened.
# See: https://developer.hashicorp.com/terraform/language/providers/requirements#best-practices-for-provider-versions
terraform {
  required_version = "1.11.3"
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

resource "google_storage_bucket" "test_bucket" {
  name          = "test-bucket-for-terraform-example-12345" # Replace with a globally unique name
  location      = "US"                                       # Choose a region or multi-region
  force_destroy = true                                      # Set to true if you want to delete non-empty buckets
  uniform_bucket_level_access = true                        # Recommended for consistent access control
}