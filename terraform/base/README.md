# Base Infrastructure

This module deploys the foundational infrastructure components for the CTF environment on Google Cloud Platform (GCP).

## Overview

The base infrastructure includes:

- **VPC Network**: Custom network with subnets and firewall rules
- **GKE Cluster**: Regional Kubernetes cluster with node pools
- **Datadog Monitoring**: Datadog Operator and Agent configuration
- **GitHub Container Registry Authentication**: For pulling private container images

## Prerequisites

Before deploying this module, ensure you have:

1. **GCP Project**: A GCP project with billing enabled
2. **Required APIs**: Enable the following APIs in your GCP project:
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable container.googleapis.com
   gcloud services enable sqladmin.googleapis.com
   gcloud services enable run.googleapis.com
   gcloud services enable storage.googleapis.com
   ```
3. **Service Account**: A service account with Owner permissions (default: `yuta-sa`)
4. **Datadog Account**: Valid Datadog API key
5. **GitHub Account**: Personal Access Token with `read:packages` scope

## Required Variables

Create a `terraform.tfvars` file in this directory with the following variables:

```hcl
# Datadog API Key (required)
dd_api_key = "your-datadog-api-key-here"

# Allowed IP addresses for firewall rules (required)
allowed_ips = ["YOUR_IP_ADDRESS/32", "ANOTHER_IP_ADDRESS/32"]

# GitHub Container Registry Authentication (required)
github_username = "your-github-username"
github_email = "your-github-email@example.com"
ghcr_access_token = "github_pat_your_token_here"

# Optional: Override default values
project_id = "your-gcp-project-id"
region = "asia-northeast1"
gke_node_type = "e2-medium"
gke_release_channel = "REGULAR"
```

### Variable Descriptions

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `dd_api_key` | Datadog API key for monitoring | Yes | - |
| `allowed_ips` | List of IP addresses allowed through firewall | Yes | - |
| `github_username` | GitHub username for GHCR authentication | Yes | - |
| `github_email` | GitHub email for GHCR authentication | Yes | - |
| `ghcr_access_token` | GitHub Personal Access Token with `read:packages` scope | Yes | - |
| `project_id` | GCP Project ID | No | `datadog-sandbox` |
| `region` | GCP region | No | `asia-northeast1` |
| `gke_node_type` | GKE node machine type | No | `e2-medium` |
| `gke_release_channel` | GKE release channel | No | `REGULAR` |

## Deployment Steps

### Step 1: Create terraform.tfvars

Create the `terraform.tfvars` file with your specific values:

```bash
# Copy the example and modify with your values
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your actual values
```

### Step 2: Initialize Terraform

```bash
terraform init
```

This will:
- Download required providers
- Initialize the backend
- Install Terraform modules

### Step 3: Plan the Deployment

```bash
terraform plan
```

Review the planned changes to ensure they match your expectations.

### Step 4: Deploy the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### Step 5: Verify Deployment

After deployment, verify the resources:

```bash
# Check GKE cluster
gcloud container clusters list

# Check Datadog namespace
kubectl get namespaces | grep datadog

# Check Datadog Agent pods
kubectl -n datadog get pods

# Check GitHub authentication secret
kubectl -n default get secret ghcr-secret
```

## Outputs

This module provides the following outputs:

- `gke_cluster_name`: Name of the created GKE cluster
- `gke_endpoint`: Kubernetes API server endpoint
- `gke_ca_certificate`: Base64 encoded CA certificate
- `network_name`: Name of the created VPC network
- `network_id`: ID of the created VPC network
- `dd_apikey_secret_name`: Name of the Datadog API key secret

## Architecture Details

### VPC Network

- **Network Name**: `ctf-japan-master-network`
- **Subnets**: 4 subnets across different zones
  - `ctf-japan-master-subnet-a`: 10.10.1.0/24
  - `ctf-japan-master-subnet-b`: 10.10.2.0/24
  - `ctf-japan-master-subnet-c`: 10.10.3.0/24
  - `ctf-japan-master-gke-subnet-a`: 10.10.0.0/24
- **Secondary Ranges**: Pod and service IP ranges for GKE
- **Firewall Rules**: Allow traffic from specified IP addresses

### GKE Cluster

- **Name**: `ctf-japan-master-cluster`
- **Type**: Regional cluster (3 zones)
- **Node Pool**: `default-node-pool`
- **Machine Type**: `e2-medium` (configurable)
- **Auto-scaling**: 1-3 nodes
- **Release Channel**: `REGULAR`

### Datadog Monitoring

- **Namespace**: `datadog`
- **Components**:
  - Datadog Operator (Helm chart)
  - DatadogAgent Custom Resource
  - API key stored in Kubernetes secret
- **Features Enabled**:
  - APM (Application Performance Monitoring)
  - Log Collection
  - Container Security
  - Network Performance Monitoring
  - Process Monitoring

### GitHub Container Registry Authentication

- **Secret Name**: `ghcr-secret`
- **Namespace**: `default`
- **Type**: `kubernetes.io/dockerconfigjson`
- **Purpose**: Enable pulling private container images from GHCR

## Troubleshooting

### Common Issues

1. **API Key Invalid Error**
   ```
   Error: API Key invalid, dropping transaction
   ```
   **Solution**: Verify your Datadog API key is valid and has proper permissions.

2. **GitHub Authentication Failed**
   ```
   Error: 403 Forbidden when pulling from ghcr.io
   ```
   **Solution**: Ensure your GitHub Personal Access Token has `read:packages` scope.

3. **GKE Cluster Creation Failed**
   ```
   Error: Insufficient permissions
   ```
   **Solution**: Verify the service account has Owner permissions.

### Useful Commands

```bash
# Check Terraform state
terraform show

# View specific resource
terraform state show kubernetes_secret.datadog_api

# Import existing resource
terraform import kubernetes_secret.existing_secret default/existing-secret

# Refresh state
terraform refresh
```

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

**Warning**: This will delete all resources created by this module. Ensure you have backups of any important data.

## Security Considerations

- All sensitive variables are marked as `sensitive = true`
- API keys are stored in Kubernetes secrets
- Firewall rules restrict access to specified IP addresses
- Service accounts follow principle of least privilege
- GitHub tokens require minimal `read:packages` scope

## Next Steps

After successfully deploying the base infrastructure:

1. Deploy the CTFd platform: `../ctfd/`
2. Deploy the Swagstore application: `../swagstore/`

Refer to the respective module README files for detailed instructions.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.28.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 3.0.2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.37.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.28.0 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.0.2 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.7.2 |

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
| [kubernetes_secret.ghcr_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [null_resource.patch_default_serviceaccount](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_pet.primary](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_service_account.terraform_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ips"></a> [allowed\_ips](#input\_allowed\_ips) | Allowed CIDR. This is the IP address of your office or home. | `list(string)` | n/a | yes |
| <a name="input_dd_api_key"></a> [dd\_api\_key](#input\_dd\_api\_key) | Datadog API Key | `string` | n/a | yes |
| <a name="input_ghcr_access_token"></a> [ghcr\_access\_token](#input\_ghcr\_access\_token) | GitHub Personal Access Token for GHCR authentication | `string` | n/a | yes |
| <a name="input_github_email"></a> [github\_email](#input\_github\_email) | GitHub email for GHCR authentication | `string` | n/a | yes |
| <a name="input_github_username"></a> [github\_username](#input\_github\_username) | GitHub username for GHCR authentication | `string` | n/a | yes |
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