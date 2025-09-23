# CTF Infrastructure Terraform

This repository contains Terraform configurations for deploying a comprehensive CTF (Capture The Flag) infrastructure on Google Cloud Platform (GCP) with Datadog monitoring.

## Architecture Overview

The infrastructure consists of three main components deployed in sequence:

1. **Base Infrastructure** - Core GCP resources (VPC, GKE, Datadog)
2. **CTFd Platform** - CTF competition platform on Cloud Run
3. **Swagstore Application** - Sample microservices application for demonstrations

## Directory Structure

```
terraform/
├── base/          # Core infrastructure (VPC, GKE, Datadog)
├── ctfd/          # CTFd platform deployment
└── swagstore/     # Sample microservices application
```

## Deployment Order

### 1. Base Infrastructure (`terraform/base/`)

Deploys the foundational infrastructure components:

- **VPC Network**: Custom network with subnets and firewall rules
- **GKE Cluster**: Regional Kubernetes cluster with node pools
- **Datadog Monitoring**: 
  - Datadog Operator in dedicated `datadog` namespace
  - DatadogAgent Custom Resource for cluster monitoring
  - GitHub Container Registry authentication for image pulls

**Prerequisites:**
- Valid Datadog API key
- GitHub Personal Access Token with `read:packages` scope
- GCP project with required APIs enabled

**Deploy:**
```bash
cd terraform/base
terraform init
terraform plan
terraform apply
```

### 2. CTFd Platform (`terraform/ctfd/`)

Deploys the CTF competition platform:

- **Cloud SQL**: MySQL database instance for CTFd
- **Cloud Run**: CTFd application with external access
- **GCS Bucket**: File storage for uploads
- **IAM**: Service accounts and permissions

**Deploy:**
```bash
cd terraform/ctfd
terraform init
terraform plan
terraform apply
```

### 3. Swagstore Application (`terraform/swagstore/`)

Deploys sample microservices for demonstrations:

- **DatadogAgent**: Enhanced monitoring configuration
- **Microservices**: 12-sample microservices application
  - Deployed in `default` namespace
  - Includes: adservice, cartservice, checkoutservice, etc.
  - Uses GitHub Container Registry images

**Deploy:**
```bash
cd terraform/swagstore
terraform init
terraform plan
terraform apply
```

## Required Environment Variables

Before deploying, set the following environment variables:

```bash
# Base infrastructure
export TF_VAR_dd_api_key="your-datadog-api-key"
export TF_VAR_allowed_ips='["YOUR_IP_ADDRESS/32"]'
export TF_VAR_github_username="your-github-username"
export TF_VAR_github_email="your-github-email"
export TF_VAR_ghcr_access_token="your-github-token"

# CTFd platform
export TF_VAR_ctfd_user_password="your-secure-password"
export TF_VAR_ctfd_secret_key="your-secure-secret-key"
```

## Security Considerations

- All sensitive variables are marked as `sensitive = true`
- Credential files (`*.tfvars`) are excluded from version control
- GitHub Personal Access Tokens require minimal `read:packages` scope
- Datadog API keys are stored in Kubernetes secrets

## Development Status

**Note**: Tag assignment functionality is currently **Work In Progress (WIP)**. This feature will be implemented in future updates to enhance resource organization and management.

## Monitoring

The infrastructure includes comprehensive Datadog monitoring:

- **Infrastructure Monitoring**: GKE cluster and node metrics
- **Application Monitoring**: APM for microservices
- **Log Collection**: Centralized logging from all components
- **Security Monitoring**: Runtime security and compliance

## Cleanup

To destroy the infrastructure, run `terraform destroy` in reverse order:

1. `terraform/swagstore/`
2. `terraform/ctfd/`
3. `terraform/base/`