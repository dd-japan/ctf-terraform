terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.3.0"
    }
  }

  backend "gcs" {
    bucket = "ctf-terraform-tfstate"
    prefix = "ctfd"
  }

  required_version = "~> 1.12"
}

data "terraform_remote_state" "base" {
  backend = "gcs"

  config = {
    bucket = "ctf-terraform-tfstate"
    prefix = "base"
  }
}
