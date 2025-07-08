#------------------------------------------------------------------------------
# Datadog Agent
#------------------------------------------------------------------------------

resource "kubernetes_manifest" "datadog_agent" {
  manifest = provider::kubernetes::manifest_decode(templatefile("${path.module}/datadog-agent.yaml", {
    NAMESPACE_NAME = "default"
    CLUSTER_NAME   = data.terraform_remote_state.base.outputs.gke_cluster_name
    SECRETS_NAME   = data.terraform_remote_state.base.outputs.dd_apikey_secret_name
  }))

  lifecycle {
    ignore_changes = [manifest]
  }
}

#------------------------------------------------------------------------------
# Swagstore
#------------------------------------------------------------------------------

data "http" "yaml_files" {
  for_each = toset(local.yaml_urls)
  url      = each.value
}

locals {
  decoded_manifests = flatten([
    for file, http_data in data.http.yaml_files :
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
                namespace = lookup(lookup(manifest, "metadata", {}), "namespace", "default")
              }
            )
          }
        )
      }
    ]
  ])

  manifest_map = {
    for item in local.decoded_manifests :
    item.key => item.manifest
  }
}

resource "kubernetes_manifest" "swagstore" {
  for_each = local.manifest_map

  manifest = each.value

  lifecycle {
    ignore_changes = [manifest]
  }
}