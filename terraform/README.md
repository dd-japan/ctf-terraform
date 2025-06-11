# Deploy Infra resources for CTF

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.12.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.28.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.17.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.36.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.3 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.28.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.17.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.36.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google | ~> 36.0.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | ~> 10.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_iam_workload_identity_pool.github_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.github_provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_service_account_iam_member.workload_identity_account_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [helm_release.datadog_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_secret.datadog_api](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_pet.primary](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_service_account.terraform_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ip1"></a> [allowed\_ip1](#input\_allowed\_ip1) | Allowed CIDR. This is the IP address of your office or home. | `string` | n/a | yes |
| <a name="input_allowed_ip2"></a> [allowed\_ip2](#input\_allowed\_ip2) | Allowed CIDR. This is the IP address of your office or home. | `string` | n/a | yes |
| <a name="input_dd_api_key"></a> [dd\_api\_key](#input\_dd\_api\_key) | Datadog API Key | `string` | n/a | yes |
| <a name="input_enabled_services"></a> [enabled\_services](#input\_enabled\_services) | n/a | <pre>map(list(object({<br/>    log_type         = string<br/>    exempted_members = optional(list(string))<br/>  })))</pre> | <pre>{<br/>  "storage.googleapis.com": [<br/>    {<br/>      "log_type": "DATA_READ"<br/>    },<br/>    {<br/>      "log_type": "DATA_WRITE"<br/>    },<br/>    {<br/>      "log_type": "ADMIN_READ"<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | 環境に関するvariable | `string` | `"dev"` | no |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | n/a | `string` | `"dd-japan"` | no |
| <a name="input_gke_node_type"></a> [gke\_node\_type](#input\_gke\_node\_type) | GKE node pool machine type. | `string` | `"e2-medium"` | no |
| <a name="input_gke_release_channel"></a> [gke\_release\_channel](#input\_gke\_release\_channel) | GKE cluster release channel. | `string` | `"REGULAR"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type for the bastion host | `string` | `"e2-standard-2"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ------------------------------------------------------------------------------ Workload Identity Poolに関するvariable ------------------------------------------------------------------------------ Projectに関するvariable | `string` | `"datadog-sandbox"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"asia-northeast1"` | no |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | n/a | `string` | `"ctf-terraform"` | no |
| <a name="input_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#input\_tfstate\_bucket\_name) | backendに関するvariable | `string` | `"ctf-terraform-tfstate"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP zone | `string` | `"asia-northeast1-a"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Zone list to deploy GKE | `string` | `"asia-northeast1-a,asia-northeast1-b,asia-northeast1-c"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dd_apikey_secret_name"></a> [dd\_apikey\_secret\_name](#output\_dd\_apikey\_secret\_name) | The name of the secret containing the Datadog API key. |
| <a name="output_gke_ca_certificate"></a> [gke\_ca\_certificate](#output\_gke\_ca\_certificate) | The base64 encoded CA certificate used to connect to this cluster's Kubernetes master. |
| <a name="output_gke_cluster_name"></a> [gke\_cluster\_name](#output\_gke\_cluster\_name) | GKE cluster name. |
| <a name="output_gke_endpoint"></a> [gke\_endpoint](#output\_gke\_endpoint) | The endpoint of this cluster's Kubernetes master. |
| <a name="output_instruction"></a> [instruction](#output\_instruction) | n/a |
| <a name="output_network_id"></a> [network\_id](#output\_network\_id) | The ID of the VPC being created |
| <a name="output_network_name"></a> [network\_name](#output\_network\_name) | The name of the VPC being created |
| <a name="output_network_self_link"></a> [network\_self\_link](#output\_network\_self\_link) | The URI of the VPC being created |
| <a name="output_subnets_ids"></a> [subnets\_ids](#output\_subnets\_ids) | The IDs of the subnets being created |
| <a name="output_subnets_ips"></a> [subnets\_ips](#output\_subnets\_ips) | The IPs and CIDRs of the subnets being created |
| <a name="output_subnets_self_links"></a> [subnets\_self\_links](#output\_subnets\_self\_links) | The self-links of subnets being created |
<!-- END_TF_DOCS -->