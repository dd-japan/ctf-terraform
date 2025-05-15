# Terraform GCP GKE + Datadog Module

このリポジトリは、以下の構成をTerraformでプロビジョニングするためのモジュールです：

- GKE クラスタのデプロイ（Google Kubernetes Engine）
- Datadog Operator および API Key Secret の作成
- VPC ネットワークの構成

> 🚧 **WIP（Work In Progress）**：この構成は現在開発中です。  
> `common_name` にランダムな接尾辞（例：`common-name-xyz123`）が付与される仕様となっており、本番利用には注意が必要です。

---

## 🔧 前提条件

- Terraform v1.10 以上
- GCP プロジェクトと権限のあるサービスアカウント
- Datadog API Key

---

## 🚀 デプロイ手順（概要）

1. 必要な入力変数を `terraform.tfvars` に定義してください。
2. `sa_email`（サービスアカウントのメールアドレス）を正しく設定してください。
3. 初期化 & 適用：

## 📁 変数ファイル（例: terraform.tfvars）

```hcl
project_id     = "your-gcp-project-id"
region         = "asia-northeast1"
zone           = "asia-northeast1-a"
allowed_ip1    = "YOUR_IP1/32"
allowed_ip2    = "YOUR_IP2/32"
dd_api_key     = "YOUR_DATADOG_API_KEY"
sa_email       = "your-sa@your-project.iam.gserviceaccount.com"
```

```bash
terraform init
terraform plan
terraform apply
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.29.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.17.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.36.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.29.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.17.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.36.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google | ~> 36.0.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | ~> 10.0.0 |

## Resources

| Name | Type |
|------|------|
| [helm_release.datadog_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_secret.datadog_api](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_service_account.ctf_infra](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ip1"></a> [allowed\_ip1](#input\_allowed\_ip1) | Allowed CIDR. This is the IP address of your office or home. | `string` | n/a | yes |
| <a name="input_allowed_ip2"></a> [allowed\_ip2](#input\_allowed\_ip2) | Allowed CIDR. This is the IP address of your office or home. | `string` | n/a | yes |
| <a name="input_dd_api_key"></a> [dd\_api\_key](#input\_dd\_api\_key) | Datadog API Key | `string` | n/a | yes |
| <a name="input_gke_node_type"></a> [gke\_node\_type](#input\_gke\_node\_type) | GKE node pool machine type. | `string` | `"e2-medium"` | no |
| <a name="input_gke_release_channel"></a> [gke\_release\_channel](#input\_gke\_release\_channel) | GKE cluster release channel. | `string` | `"REGULAR"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type for the bastion host | `string` | `"e2-standard-2"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID for your GCP project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region | `string` | `"asia-northeast1"` | no |
| <a name="input_sa_email"></a> [sa\_email](#input\_sa\_email) | Service account email | `string` | `"xxx@xxx.iam.gserviceaccount.com"` | no |
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