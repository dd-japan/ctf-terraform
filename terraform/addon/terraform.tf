terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.37.1"
    }
  }

  backend "gcs" {
    bucket = "ctf-terraform-tfstate"
    prefix = "addon"
  }

  required_version = "~> 1.10"
}

data "terraform_remote_state" "base" {
  backend = "gcs"

  config = {
    bucket = "ctf-terraform-tfstate"
    prefix = "base"
  }
}

provider "kubernetes" {
  host                   = "https://${data.terraform_remote_state.base.outputs.gke_endpoint}"
  cluster_ca_certificate = base64decode(data.terraform_remote_state.base.outputs.gke_ca_certificate)
  token                  = data.google_client_config.default.access_token
}
