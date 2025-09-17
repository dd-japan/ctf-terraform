# CTF Infrastructure Addon Components

This Terraform module deploys additional components for the CTF infrastructure:

## Components

### 1. Datadog Agent (Kubernetes)
- **Namespace**: `datadog` - Deployed in the dedicated Datadog namespace
- **Purpose**: Monitors the Kubernetes cluster and applications
- **Configuration**: Uses DatadogAgent Custom Resource with APM, log collection, and security monitoring enabled
- **Instrumentation**: Enabled for the `default` namespace to monitor swagstore applications

### 2. Swagstore Application (Kubernetes)
- **Namespace**: `default` - Deployed in the default namespace
- **Purpose**: Sample microservices application for CTF demonstrations
- **Components**: Includes 12 microservices (adservice, cartservice, checkoutservice, etc.)
- **Source**: Deployed from external YAML manifests via HTTP data source

### 3. CTFd Application (Cloud Run)
- **Purpose**: CTF platform application
- **Database**: MySQL Cloud SQL instance
- **Storage**: GCS bucket for file uploads
- **Access**: Public access enabled via IAM

## Namespace Strategy

- **`datadog` namespace**: Contains all Datadog monitoring components
- **`default` namespace**: Contains the swagstore microservices application
- **Cloud Run**: CTFd application runs outside of Kubernetes

This separation ensures proper isolation between monitoring infrastructure and application workloads.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.28.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | ~> 6.28.0 |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.37.1 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_service.ctfd](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service) | resource |
| [google_cloud_run_service_iam_member.public_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_member) | resource |
| [google_project_iam_member.ctfd_cloudsql_client](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.ctfd_cloud_run](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_sql_database.ctfd](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.ctfd_japan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_user.ctfduser](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [google_storage_bucket.ctfd_uploads](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.ctfd_storage_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [kubernetes_manifest.datadog_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.swagstore](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [random_pet.ctfd](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [http_http.yaml_files](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
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
| <a name="input_ctfd_instance_tier"></a> [ctfd\_instance\_tier](#input\_ctfd\_instance\_tier) | The machine type for the CTFD Japan Cloud SQL instance | `string` | `"db-perf-optimized-N-8"` | no |
| <a name="input_ctfd_maintenance_update_track"></a> [ctfd\_maintenance\_update\_track](#input\_ctfd\_maintenance\_update\_track) | The update track for maintenance for CTFD Japan | `string` | `"stable"` | no |
| <a name="input_ctfd_maintenance_window_day"></a> [ctfd\_maintenance\_window\_day](#input\_ctfd\_maintenance\_window\_day) | The day of the week for maintenance for CTFD Japan (1 = Monday, 7 = Sunday) | `number` | `7` | no |
| <a name="input_ctfd_maintenance_window_hour"></a> [ctfd\_maintenance\_window\_hour](#input\_ctfd\_maintenance\_window\_hour) | The hour of the day for maintenance for CTFD Japan (UTC) | `number` | `0` | no |
| <a name="input_ctfd_secret_key"></a> [ctfd\_secret\_key](#input\_ctfd\_secret\_key) | Secret key for CTFd application | `string` | `"changeme123456789!"` | no |
| <a name="input_ctfd_user_password"></a> [ctfd\_user\_password](#input\_ctfd\_user\_password) | Password for the CTFD user | `string` | `"changeme123456789!"` | no |
| <a name="input_ctfd_zone"></a> [ctfd\_zone](#input\_ctfd\_zone) | The GCP zone for the CTFD Japan Cloud SQL instance | `string` | `"asia-northeast1-b"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `"datadog-sandbox"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"asia-northeast1"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP zone | `string` | `"asia-northeast1-a"` | no |

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
<!-- END_TF_DOCS -->