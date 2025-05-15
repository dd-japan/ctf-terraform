#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------
locals {
  common_tags = {
    terraform               = "true"
    environment             = "test"
    owner                   = "xxx"
    deperatment             = "salesengineering"
    location                = "tokyo"
    please_keep_my_resource = true
  }
  common_name = "ctf-infra-tmp"

  manifest_files = [
    "adservice.yaml",
    "cartservice.yaml",
    "checkoutservice.yaml",
    "currencyservice.yaml",
    "emailservice.yaml",
    "frontend.yaml",
    "loadgenerator.yaml",
    "paymentservice.yaml",
    "productcatalogservice.yaml",
    "recommendationservice.yaml",
    "redis.yaml",
    "shippingservice.yaml"
  ]

  yaml_urls = [
    for f in local.manifest_files :
    "https://raw.githubusercontent.com/dd-japan/ctf-swagstore/prep-for-freee/kubernetes-manifests/${f}"
  ]
}

variable "project_id" {
  description = "The ID for your GCP project"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "asia-northeast1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "asia-northeast1-a"
}
