# Deploy Infra resources for CTF

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
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 3.0.2 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.37.1 |
| <a name="provider_random"></a> [random](#provider\_random) | ~> 3.6.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google | ~> 36.0.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | 10.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_service.ctfd](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service) | resource |
| [google_cloud_run_service_iam_member.public_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_member) | resource |
| [google_project_iam_member.ctfd_cloudsql_client](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.compute](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.run](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.sqladmin](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.storage](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.ctfd_cloud_run](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_sql_database.ctfd](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.ctfd_japan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_user.ctfduser](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [google_storage_bucket.ctfd_uploads](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.ctfd_storage_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [helm_release.datadog_operator](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_secret.datadog_api](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_pet.ctfd](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_pet.primary](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | Allowed CIDR. This is the IP address of your office or home. | `list(string)` | n/a | yes |
| <a name="input_ctfd_availability_type"></a> [ctfd\_availability\_type](#input\_ctfd\_availability\_type) | The availability type for the CTFD Japan Cloud SQL instance | `string` | `"REGIONAL"` | no |
| <a name="input_ctfd_backup_location"></a> [ctfd\_backup\_location](#input\_ctfd\_backup\_location) | The location for backups for CTFD Japan | `string` | `"asia"` | no |
| <a name="input_ctfd_backup_retention_count"></a> [ctfd\_backup\_retention\_count](#input\_ctfd\_backup\_retention\_count) | The number of backups to retain for CTFD Japan | `number` | `15` | no |
| <a name="input_ctfd_backup_start_time"></a> [ctfd\_backup\_start\_time](#input\_ctfd\_backup\_start\_time) | The start time for automated backups for CTFD Japan | `string` | `"05:00"` | no |
| <a name="input_ctfd_database_charset"></a> [ctfd\_database\_charset](#input\_ctfd\_database\_charset) | The charset for the CTFD database | `string` | `"utf8mb4"` | no |
| <a name="input_ctfd_database_collation"></a> [ctfd\_database\_collation](#input\_ctfd\_database\_collation) | The collation for the CTFD database | `string` | `"utf8mb4_0900_ai_ci"` | no |
| <a name="input_ctfd_database_name"></a> [ctfd\_database\_name](#input\_ctfd\_database\_name) | The name of the CTFD database | `string` | `"ctfd"` | no |
| <a name="input_ctfd_database_user"></a> [ctfd\_database\_user](#input\_ctfd\_database\_user) | The CTFD database user name | `string` | `"ctfduser"` | no |
| <a name="input_ctfd_database_version"></a> [ctfd\_database\_version](#input\_ctfd\_database\_version) | The MySQL version for the CTFD Japan Cloud SQL instance | `string` | `"MYSQL_8_0_40"` | no |
| <a name="input_ctfd_disk_size"></a> [ctfd\_disk\_size](#input\_ctfd\_disk\_size) | The disk size in GB for the CTFD Japan Cloud SQL instance | `number` | `250` | no |
| <a name="input_ctfd_disk_type"></a> [ctfd\_disk\_type](#input\_ctfd\_disk\_type) | The disk type for the CTFD Japan Cloud SQL instance | `string` | `"PD_SSD"` | no |
| <a name="input_ctfd_edition"></a> [ctfd\_edition](#input\_ctfd\_edition) | The edition of the CTFD Japan Cloud SQL instance | `string` | `"ENTERPRISE_PLUS"` | no |
| <a name="input_ctfd_instance_name"></a> [ctfd\_instance\_name](#input\_ctfd\_instance\_name) | The name of the CTFD Japan Cloud SQL instance | `string` | `"ctfd-japan"` | no |
| <a name="input_ctfd_instance_tier"></a> [ctfd\_instance\_tier](#input\_ctfd\_instance\_tier) | The machine type for the CTFD Japan Cloud SQL instance | `string` | `"db-perf-optimized-N-8"` | no |
| <a name="input_ctfd_maintenance_update_track"></a> [ctfd\_maintenance\_update\_track](#input\_ctfd\_maintenance\_update\_track) | The update track for maintenance for CTFD Japan | `string` | `"stable"` | no |
| <a name="input_ctfd_maintenance_window_day"></a> [ctfd\_maintenance\_window\_day](#input\_ctfd\_maintenance\_window\_day) | The day of the week for maintenance for CTFD Japan (1 = Monday, 7 = Sunday) | `number` | `7` | no |
| <a name="input_ctfd_maintenance_window_hour"></a> [ctfd\_maintenance\_window\_hour](#input\_ctfd\_maintenance\_window\_hour) | The hour of the day for maintenance for CTFD Japan (UTC) | `number` | `0` | no |
| <a name="input_ctfd_secret_key"></a> [ctfd\_secret\_key](#input\_ctfd\_secret\_key) | Secret key for CTFd application | `string` | `null` | no |
| <a name="input_ctfd_user_password"></a> [ctfd\_user\_password](#input\_ctfd\_user\_password) | Password for the CTFD user | `string` | `null` | no |
| <a name="input_ctfd_zone"></a> [ctfd\_zone](#input\_ctfd\_zone) | The GCP zone for the CTFD Japan Cloud SQL instance | `string` | `"asia-northeast1-b"` | no |
| <a name="input_dd_api_key"></a> [dd\_api\_key](#input\_dd\_api\_key) | Datadog API Key | `string` | n/a | yes |
| <a name="input_gke_node_type"></a> [gke\_node\_type](#input\_gke\_node\_type) | GKE node pool machine type. | `string` | `"e2-medium"` | no |
| <a name="input_gke_release_channel"></a> [gke\_release\_channel](#input\_gke\_release\_channel) | GKE cluster release channel. | `string` | `"REGULAR"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type for the bastion host | `string` | `"e2-standard-2"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Projectに関するvariable | `string` | `"datadog-sandbox"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"asia-northeast1"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP zone | `string` | `"asia-northeast1-a"` | no |
| <a name="input_zones"></a> [zones](#input\_zones) | Zone list to deploy GKE | `string` | `"asia-northeast1-a,asia-northeast1-b,asia-northeast1-c"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ctfd_database_name"></a> [ctfd\_database\_name](#output\_ctfd\_database\_name) | The name of the CTFD database |
| <a name="output_ctfd_japan_connection_name"></a> [ctfd\_japan\_connection\_name](#output\_ctfd\_japan\_connection\_name) | The connection name of the CTFD Japan Cloud SQL instance |
| <a name="output_ctfd_japan_public_ip"></a> [ctfd\_japan\_public\_ip](#output\_ctfd\_japan\_public\_ip) | The public IP address of the CTFD Japan Cloud SQL instance |
| <a name="output_ctfd_japan_self_link"></a> [ctfd\_japan\_self\_link](#output\_ctfd\_japan\_self\_link) | The URI of the CTFD Japan Cloud SQL instance |
| <a name="output_ctfd_japan_service_account_email"></a> [ctfd\_japan\_service\_account\_email](#output\_ctfd\_japan\_service\_account\_email) | The service account email address assigned to the CTFD Japan instance |
| <a name="output_ctfd_service_account_email"></a> [ctfd\_service\_account\_email](#output\_ctfd\_service\_account\_email) | Email of the CTFd Cloud Run service account |
| <a name="output_ctfd_service_url"></a> [ctfd\_service\_url](#output\_ctfd\_service\_url) | URL of the CTFd Cloud Run service |
| <a name="output_ctfd_uploads_bucket"></a> [ctfd\_uploads\_bucket](#output\_ctfd\_uploads\_bucket) | Name of the CTFd uploads GCS bucket |
| <a name="output_ctfd_user_name"></a> [ctfd\_user\_name](#output\_ctfd\_user\_name) | The name of the CTFD user |
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