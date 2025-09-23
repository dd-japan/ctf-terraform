data "google_client_config" "default" {}

#------------------------------------------------------------------------------
# Datadog Agent
#------------------------------------------------------------------------------

resource "kubernetes_manifest" "datadog_agent" {
  manifest = provider::kubernetes::manifest_decode(templatefile("${path.module}/datadog-agent.yaml", {
    NAMESPACE_NAME = "datadog"
    CLUSTER_NAME   = data.terraform_remote_state.base.outputs.gke_cluster_name
    SECRETS_NAME   = data.terraform_remote_state.base.outputs.dd_apikey_secret_name
  }))
}

#------------------------------------------------------------------------------
# Swagstore
#------------------------------------------------------------------------------

data "http" "swagstore_yaml_files" {
  for_each = toset(local.swagstore_yaml_urls)
  url      = each.value
}

locals {
  swagstore_decoded_manifests = flatten([
    for file, http_data in data.http.swagstore_yaml_files :
    [
      for manifest in provider::kubernetes::manifest_decode_multi(http_data.response_body) :
      {
        key = "${lower(manifest.kind)}-${manifest.metadata.name}-${lookup(manifest.metadata, "namespace", "default")}"
        manifest = merge(
          manifest,
          {
            metadata = merge(
              lookup(manifest, "metadata", {}),
              {
                # Force swagstore applications to use default namespace
                namespace = "default"
              }
            )
          }
        )
      }
    ]
  ])

  swagstore_manifest_map = {
    for item in local.swagstore_decoded_manifests :
    item.key => item.manifest
  }
}

resource "kubernetes_manifest" "swagstore" {
  for_each = local.swagstore_manifest_map

  manifest = each.value
}

#------------------------------------------------------------------------------
# Responseservice
#------------------------------------------------------------------------------

data "http" "responseservice_yaml_files" {
  for_each = toset(local.responseservice_yaml_urls)
  url      = each.value
}

locals {
  responseservice_decoded_manifests = flatten([
    for file, http_data in data.http.responseservice_yaml_files :
    [
      for manifest in provider::kubernetes::manifest_decode_multi(http_data.response_body) :
      {
        key = "${lower(manifest.kind)}-${manifest.metadata.name}-${lookup(manifest.metadata, "namespace", "default")}"
        manifest = merge(
          manifest,
          {
            metadata = merge(
              lookup(manifest, "metadata", {}),
              {
                # Force responseservice applications to use default namespace
                namespace = "default"
              }
            )
          }
        )
      }
    ]
  ])

  responseservice_manifest_map = {
    for item in local.responseservice_decoded_manifests :
    item.key => item.manifest
  }
}

resource "kubernetes_manifest" "responseservice" {
  for_each = local.responseservice_manifest_map

  manifest = each.value
}