#------------------------------------------------------------------------------
# Common
#------------------------------------------------------------------------------

locals {
  common_tags = {
    terraform               = "true"
    deperatment             = "salesengineering"
    please_keep_my_resource = true
  }

  # Swagstore
  swagstore_manifest_files = [
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

  swagstore_yaml_urls = [
    for swagstore in local.swagstore_manifest_files :
    "https://raw.githubusercontent.com/dd-japan/ctf-swagstore/refs/heads/2025-1H/kubernetes-manifests/${swagstore}"
  ]

  # Responseservice
  responseservice_manifest_files = [
    "configmap.yaml",
    "k6-configmap.yaml",
    "k6.yaml",
    "responseservice-v1.yaml",
    "responseservice-v2.yaml"
  ]

  responseservice_yaml_urls = [
    for responseservice in local.responseservice_manifest_files :
    "https://raw.githubusercontent.com/dd-japan/ctf-swagstore/refs/heads/2025-1H/kubernetes-manifests/responseservice/${responseservice}"
  ]
}