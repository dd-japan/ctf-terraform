# Since the versions of the module’s callers may differ, the version constraints should be loosened.
# See: https://developer.hashicorp.com/terraform/language/providers/requirements#best-practices-for-provider-versions
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.28.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.6"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.3"
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
    prefix = "datadog-sandbox"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  token                  = data.google_client_config.default.access_token
}

provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.endpoint}"
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
    token                  = data.google_client_config.default.access_token
  }
}