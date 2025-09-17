# Deploy Infra resources for CTF

## Prerequisites

Before running Terraform, you need to manually enable the following Google Cloud APIs:

```bash
# Enable required APIs
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable storage.googleapis.com
```

## Required Environment Variables

Set the following environment variables before running Terraform:

```bash
export TF_VAR_allowed_ips='["YOUR_IP_ADDRESS/32"]'
export TF_VAR_dd_api_key="your-datadog-api-key"
export TF_VAR_ctfd_user_password="your-secure-password"
export TF_VAR_ctfd_secret_key="your-secure-secret-key"
```

## Datadog Monitoring

This Terraform configuration deploys Datadog monitoring components in a dedicated Kubernetes namespace:

- **Namespace**: `datadog` - A dedicated namespace for all Datadog-related resources
- **Secret**: `datadog-secret` - Contains the Datadog API key for authentication
- **Operator**: `datadog-operator` - Helm chart deployment of the Datadog Operator

The Datadog resources are deployed in the following order:
1. `datadog` namespace is created
2. `datadog-secret` is created in the datadog namespace
3. `datadog-operator` Helm release is deployed in the datadog namespace

This ensures proper isolation and organization of monitoring components.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.28.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.3 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.28.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.0.2 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google | ~> 36.0.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | 10.0.0 |

## Resources

| Name | Type |
|------|------|
| [helm_release.datadog_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.datadog](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.datadog_api](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_pet.primary](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_service_account.terraform_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | Allowed CIDR. This is the IP address of your office or home. | `list(string)` | n/a | yes |
| <a name="input_dd_api_key"></a> [dd\_api\_key](#input\_dd\_api\_key) | Datadog API Key | `string` | n/a | yes |
| <a name="input_gke_node_type"></a> [gke\_node\_type](#input\_gke\_node\_type) | GKE node pool machine type. | `string` | `"e2-medium"` | no |
| <a name="input_gke_release_channel"></a> [gke\_release\_channel](#input\_gke\_release\_channel) | GKE cluster release channel. | `string` | `"REGULAR"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type for the bastion host | `string` | `"e2-standard-2"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project variables | `string` | `"datadog-sandbox"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"asia-northeast1"` | no |
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