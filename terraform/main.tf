resource "google_storage_bucket" "test_bucket_datadog_japan" {
  name          = "test-bucket-for-terraform-example-678910" # Replace with a globally unique name
  location      = "US"                                       # Choose a region or multi-region
  force_destroy = true                                      # Set to true if you want to delete non-empty buckets
  uniform_bucket_level_access = true                        # Recommended for consistent access control
}