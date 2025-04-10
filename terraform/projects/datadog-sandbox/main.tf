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

# tfstate を参照するためのプロジェクト
provider "google" {
  project = var.project_id
  region  = var.region
}

# Workload Identity
resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = var.project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "github-pool"
  description               = "for github workflows"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                   = var.project_id
  workload_identity_pool_id = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id

  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "github-provider"
  description                        = "for github workflows"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  attribute_condition = "assertion.repository_owner == '${var.github_org}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "ctf_github_actions_terraform" {
  project      = var.project_id
  account_id   = "ctf-github-actions-terraform"
  display_name = "ctf-github-actions-terraform"
  description  = "GitHub Actions for Terraform to CTF Japan"
}

# Workload Identityによる認証を許可するIAMバインディング設定
resource "google_service_account_iam_member" "workload_identity_account_iam" {
  service_account_id = google_service_account.ctf_github_actions_terraform.name
  role               = "roles/iam.workloadIdentityUser"
  member  = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_org}/${var.repo_name}"
}

# Workload Identity プリンシパルに対するアクセス権限を付与（Resource の作成・更新・削除）
# resource "google_project_iam_member" "the_principal" {
#   for_each = toset([
#     "roles/editor",
#     "roles/resourcemanager.projectIamAdmin", # Project IAM Admin 
#     "roles/logging.configWriter",            # Logs Configuration Writer
#   ])
#   project = var.project_id
#   role    = each.value
#   member  = "serviceAccount:${google_service_account.ctf_github_actions_terraform.email}"
# }