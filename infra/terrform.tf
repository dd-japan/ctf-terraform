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
  /*
  backend "gcs" {
    bucket = "xxxx"
  }
*/
  required_version = "~> 1.10"
}