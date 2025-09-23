# CTFd Platform

This module deploys the CTFd platform on Google Cloud Run with MySQL Cloud SQL database and GCS storage for file uploads.

## Overview

The CTFd module includes:

- **CTFd Application**: CTF platform running on Cloud Run
- **MySQL Database**: Cloud SQL instance for CTFd data storage
- **File Storage**: GCS bucket for CTFd file uploads
- **Service Account**: Dedicated service account with necessary permissions
- **IAM Policies**: Proper access controls for database and storage
- **Google Cloud Tags**: External access policy tags for governance

## Prerequisites

Before deploying this module, ensure you have:

1. **Base Infrastructure**: The base infrastructure must be deployed first (`../base/`)
2. **GCP Project**: A Google Cloud Project with billing enabled
3. **Required APIs**: Cloud Run, Cloud SQL, and Storage APIs enabled
4. **Network**: VPC network from base infrastructure

## Required Variables

Create a `terraform.tfvars` file in this directory with the following variables:

```hcl
# Project Configuration (optional - uses base infrastructure values)
project_id = "your-gcp-project-id"
region = "asia-northeast1"
zone = "asia-northeast1-a"

# CTFd Database Configuration (optional - uses defaults)
ctfd_database_version = "MYSQL_8_0_40"
ctfd_instance_tier = "db-perf-optimized-N-8"
ctfd_disk_size = 250
ctfd_disk_type = "PD_SSD"
ctfd_availability_type = "REGIONAL"
ctfd_edition = "ENTERPRISE_PLUS"
ctfd_zone = "asia-northeast1-b"

# Database Settings (optional - uses defaults)
ctfd_database_name = "ctfd"
ctfd_database_charset = "utf8mb4"
ctfd_database_collation = "utf8mb4_0900_ai_ci"
ctfd_database_user = "ctfduser"

# Sensitive Variables (required if overriding defaults)
ctfd_user_password = "your-secure-password"
ctfd_secret_key = "your-secure-secret-key"

# Backup Configuration (optional - uses defaults)
ctfd_backup_start_time = "05:00"
ctfd_backup_retention_count = 15
ctfd_backup_location = "asia"

# Maintenance Window (optional - uses defaults)
ctfd_maintenance_window_day = 7  # Sunday
ctfd_maintenance_window_hour = 0  # UTC
ctfd_maintenance_update_track = "stable"

# Organization ID for tags (required)
organization_id = "1234567890"
```

## Deployment Steps

### Step 1: Verify Base Infrastructure

Ensure the base infrastructure is deployed and running:

```bash
# Check if base infrastructure is deployed
cd ../base
terraform output

# Verify GKE cluster is running
gcloud container clusters list

# Check VPC network exists
gcloud compute networks list
```

### Step 2: Create terraform.tfvars (Optional)

If you need to override default values, create the `terraform.tfvars` file:

```bash
# Create terraform.tfvars with your specific values
cat > terraform.tfvars << EOF
# Add your custom values here
ctfd_user_password = "your-secure-password"
ctfd_secret_key = "your-secure-secret-key"
EOF
```

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Plan the Deployment

```bash
terraform plan
```

Review the planned changes to ensure they match your expectations.

### Step 5: Deploy the Application

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### Step 6: Verify Deployment

After deployment, verify the resources:

```bash
# Check Cloud Run service
gcloud run services list --region=asia-northeast1

# Check Cloud SQL instance
gcloud sql instances list

# Check GCS bucket
gsutil ls

# Check service account
gcloud iam service-accounts list
```

## Architecture Details

### CTFd Application (Cloud Run)

- **Service**: CTFd platform running on Cloud Run
- **Image**: `ctfd/ctfd:latest`
- **Port**: 8000
- **Scaling**: Min 1, Max 3 instances
- **Environment**: Gen2 execution environment
- **Access**: Public access enabled via IAM

### MySQL Database (Cloud SQL)

- **Version**: MySQL 8.0.40
- **Tier**: db-perf-optimized-N-8
- **Storage**: 250GB SSD
- **Availability**: Regional (high availability)
- **Backup**: Automated daily backups
- **Maintenance**: Weekly maintenance window

### File Storage (GCS)

- **Bucket**: CTFd file uploads storage
- **Access**: Service account with object admin permissions
- **Lifecycle**: Configurable retention policies

### Service Account

- **Purpose**: Dedicated service account for CTFd
- **Permissions**:
  - Cloud SQL Client
  - Storage Object Admin
  - Cloud Run Invoker

### External Access Policy

- **Label**: `external-access: allowed` - Applied to Cloud Run service metadata
- **Purpose**: Indicates that external access is permitted for this service
- **Note**: Cloud Run services do not support Google Cloud Tags binding, so metadata labels are used instead

## Configuration Details

### Environment Variables

The CTFd application is configured with:

- **DATABASE_URL**: MySQL connection string with Cloud SQL socket
- **UPLOAD_FOLDER**: `/var/uploads` for file uploads
- **SECRET_KEY**: Application secret key for security

### Database Connection

CTFd connects to MySQL using Cloud SQL socket:

```
mysql+pymysql://ctfduser:password@/ctfd?unix_socket=/cloudsql/project:region:instance
```

### File Uploads

- Files are stored in GCS bucket
- Service account has object admin permissions
- Upload folder is mounted as `/var/uploads`

## Access and Usage

### Accessing CTFd

1. **Get Cloud Run URL**:
   ```bash
   gcloud run services describe ctfd-service --region=asia-northeast1 --format="value(status.url)"
   ```

2. **Access via Browser**: Open the URL in your web browser

3. **Initial Setup**: Follow CTFd setup wizard to configure admin user

### Admin Configuration

1. **Create Admin User**: First-time setup creates admin account
2. **Configure Settings**: Set up CTFd configuration
3. **Upload Challenges**: Add CTF challenges and files
4. **Manage Users**: Invite participants and manage teams

## Monitoring and Logging

### Cloud Run Logs

```bash
# View CTFd application logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=ctfd-service" --limit=50

# Stream logs in real-time
gcloud logging tail "resource.type=cloud_run_revision AND resource.labels.service_name=ctfd-service"
```

### Database Monitoring

```bash
# Check database status
gcloud sql instances describe ctfd-instance

# View database logs
gcloud logging read "resource.type=gce_instance AND resource.labels.instance_id=ctfd-instance" --limit=20
```

### Storage Monitoring

```bash
# Check bucket usage
gsutil du -sh gs://ctfd-uploads-bucket

# List uploaded files
gsutil ls -la gs://ctfd-uploads-bucket/
```

## Troubleshooting

### Common Issues

1. **Cloud Run Service Not Starting**
   ```
   Error: Service failed to start
   ```
   **Solution**: Check Cloud Run logs and verify database connection string.

2. **Database Connection Failed**
   ```
   Error: Can't connect to MySQL server
   ```
   **Solution**: Verify Cloud SQL instance is running and service account has proper permissions.

3. **File Upload Issues**
   ```
   Error: Permission denied for bucket
   ```
   **Solution**: Check service account IAM permissions for GCS bucket.

4. **Memory Issues**
   ```
   Error: Container killed due to memory limit
   ```
   **Solution**: Increase Cloud Run memory allocation or optimize CTFd configuration.

### Useful Commands

```bash
# Check Cloud Run service status
gcloud run services describe ctfd-service --region=asia-northeast1

# Check database connectivity
gcloud sql connect ctfd-instance --user=ctfduser --database=ctfd

# Check service account permissions
gcloud projects get-iam-policy your-project-id --flatten="bindings[].members" --format="table(bindings.role)" --filter="bindings.members:ctfd-service@your-project-id.iam.gserviceaccount.com"

# View recent logs
gcloud logging read "resource.type=cloud_run_revision" --limit=20 --format="table(timestamp,severity,textPayload)"
```

## Security Considerations

- **Database Security**: MySQL instance uses SSL connections
- **Service Account**: Minimal required permissions
- **Network Security**: Cloud Run uses Google's secure infrastructure
- **File Storage**: GCS bucket with proper access controls
- **Secrets**: Sensitive variables marked as `sensitive = true`

## Backup and Recovery

### Database Backups

- **Automated**: Daily backups with 15-day retention
- **Manual**: Create on-demand backups
- **Recovery**: Point-in-time recovery available

### File Storage Backups

- **GCS**: Built-in redundancy and versioning
- **Lifecycle**: Configurable retention policies
- **Cross-Region**: Optional cross-region replication

## Scaling and Performance

### Cloud Run Scaling

- **Automatic**: Scales based on request volume
- **Min Scale**: 1 instance always running
- **Max Scale**: 3 instances maximum
- **CPU**: Non-throttled with startup boost

### Database Performance

- **Tier**: Performance-optimized machine type
- **Storage**: SSD for better I/O performance
- **Caching**: Data cache enabled for improved performance

## Cleanup

To destroy the CTFd platform:

```bash
terraform destroy
```

**Warning**: This will delete all CTFd resources including:
- Cloud Run service
- Cloud SQL instance and data
- GCS bucket and files
- Service account and IAM bindings

## Next Steps

After successfully deploying CTFd:

1. **Access CTFd**: Open the Cloud Run URL in your browser
2. **Initial Setup**: Complete the CTFd setup wizard
3. **Configure Challenges**: Upload CTF challenges and files
4. **Invite Participants**: Set up teams and user accounts
5. **Monitor Performance**: Use Cloud Logging and Monitoring
6. **Backup Strategy**: Configure additional backup policies if needed

## Support

For issues or questions, please refer to the base infrastructure README or contact the Datadog Japan Sales Engineering team.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.12 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 7.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 7.3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_service.ctfd](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service) | resource |
| [google_project_iam_binding.ctfd_cloudsql_client](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_service_account.ctfd_cloud_run](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_sql_database.ctfd](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.ctfd](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_user.ctfduser](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [google_storage_bucket.ctfd_uploads](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.ctfd_storage_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_tags_tag_binding.ctfd_external_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_binding) | resource |
| [google_tags_tag_key.external_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_key) | resource |
| [google_tags_tag_value.allowed](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_value) | resource |
| [random_pet.ctfd](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ctfd_availability_type"></a> [ctfd\_availability\_type](#input\_ctfd\_availability\_type) | The availability type for the CTFD Japan Cloud SQL instance | `string` | `"REGIONAL"` | no |
| <a name="input_ctfd_database_charset"></a> [ctfd\_database\_charset](#input\_ctfd\_database\_charset) | The charset for the CTFD database | `string` | `"utf8mb4"` | no |
| <a name="input_ctfd_database_collation"></a> [ctfd\_database\_collation](#input\_ctfd\_database\_collation) | The collation for the CTFD database | `string` | `"utf8mb4_0900_ai_ci"` | no |
| <a name="input_ctfd_database_name"></a> [ctfd\_database\_name](#input\_ctfd\_database\_name) | The name of the CTFD database | `string` | `"ctfd"` | no |
| <a name="input_ctfd_database_user"></a> [ctfd\_database\_user](#input\_ctfd\_database\_user) | The CTFD database user name | `string` | `"ctfduser"` | no |
| <a name="input_ctfd_database_version"></a> [ctfd\_database\_version](#input\_ctfd\_database\_version) | The MySQL version for the CTFD Japan Cloud SQL instance | `string` | `"MYSQL_8_0_40"` | no |
| <a name="input_ctfd_disk_size"></a> [ctfd\_disk\_size](#input\_ctfd\_disk\_size) | The disk size in GB for the CTFD Japan Cloud SQL instance | `number` | `250` | no |
| <a name="input_ctfd_disk_type"></a> [ctfd\_disk\_type](#input\_ctfd\_disk\_type) | The disk type for the CTFD Japan Cloud SQL instance | `string` | `"PD_SSD"` | no |
| <a name="input_ctfd_edition"></a> [ctfd\_edition](#input\_ctfd\_edition) | The edition of the CTFD Japan Cloud SQL instance | `string` | `"ENTERPRISE_PLUS"` | no |
| <a name="input_ctfd_instance_tier"></a> [ctfd\_instance\_tier](#input\_ctfd\_instance\_tier) | The machine type for the CTFD Japan Cloud SQL instance | `string` | `"db-perf-optimized-N-8"` | no |
| <a name="input_ctfd_secret_key"></a> [ctfd\_secret\_key](#input\_ctfd\_secret\_key) | Secret key for CTFd application | `string` | `"changeme123456789!"` | no |
| <a name="input_ctfd_user_password"></a> [ctfd\_user\_password](#input\_ctfd\_user\_password) | Password for the CTFD user | `string` | `"changeme123456789!"` | no |
| <a name="input_ctfd_zone"></a> [ctfd\_zone](#input\_ctfd\_zone) | The GCP zone for the CTFD Japan Cloud SQL instance | `string` | `"asia-northeast1-b"` | no |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | Organization ID for Google Cloud tags | `string` | `"1234567890"` | no |
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