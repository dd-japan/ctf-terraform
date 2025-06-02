# Workload Identity
resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = var.project_id
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "github-actions-pool"
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

data "google_service_account" "terraform_sa" {
  # "yuta-sa" は Owner 権限を持つ Service Account であるため、Workload Identity による認証を許可する
  account_id = "yuta-sa"
}

# Workload Identityによる認証を許可するIAMバインディング設定
resource "google_service_account_iam_member" "workload_identity_account_iam" {
  service_account_id = data.google_service_account.terraform_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member  = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_org}/${var.repo_name}"
}
