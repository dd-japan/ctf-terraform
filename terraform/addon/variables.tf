#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------
locals {
  common_tags = {
    terraform               = "true"
    environment             = "test"
    owner                   = "dd-japan"
    deperatment             = "salesengineering"
    location                = "tokyo"
    please_keep_my_resource = true
  }
  common_name = "ctf-test"

  # Swagstore
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
    "https://raw.githubusercontent.com/dd-japan/ctf-swagstore/refs/heads/2025-1H/kubernetes-manifests/${f}"
  ]
}