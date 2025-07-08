terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.29.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.6"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.36.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17.0"
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
    prefix = "datadog-sandbox"
  }
}

provider "google" {
  region  = var.region
  project = var.project_id
}

provider "kubernetes" {
  host                   = "https://${data.terraform_remote_state.base.outputs.gke_endpoint}"
  cluster_ca_certificate = base64decode(data.terraform_remote_state.base.outputs.gke_ca_certificate)
  token                  = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes {
    host                   = "https://${data.terraform_remote_state.base.outputs.gke_endpoint}"
    cluster_ca_certificate = base64decode(data.terraform_remote_state.base.outputs.gke_ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}