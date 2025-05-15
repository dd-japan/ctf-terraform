provider "google" {
  region  = var.region
  project = var.project_id
}

provider "kubernetes" {
  host                   = "https://${data.terraform_remote_state.k8s.outputs.gke_endpoint}"
  cluster_ca_certificate = base64decode(data.terraform_remote_state.k8s.outputs.gke_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.terraform_remote_state.k8s.outputs.gke_endpoint}"
    cluster_ca_certificate = base64decode(data.terraform_remote_state.k8s.outputs.gke_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}