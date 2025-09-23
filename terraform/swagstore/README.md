# Swagstore Application

This module deploys the Swagstore microservices application and enhanced Datadog monitoring configuration.

## Overview

- Enhanced DatadogAgent with AP1 site
- 12-sample microservices for demonstrations
- Responseservice microservices with load testing capabilities
- Automatic deployment from GitHub repository
- All services deployed in `default` namespace

## Prerequisites

1. Base Infrastructure deployed (`../base/`)
2. GKE Cluster running with Datadog monitoring
3. GitHub access to `dd-japan/ctf-swagstore` repository

## Required Variables

Create `terraform.tfvars`:

```hcl
# Project Configuration (optional)
project_id = "your-gcp-project-id"
region = "asia-northeast1"
zone = "asia-northeast1-a"

# Sensitive Variables (required if overriding defaults)
ctfd_user_password = "your-secure-password"
ctfd_secret_key = "your-secure-secret-key"
```

## Deployment Steps

### Step 1: Verify Base Infrastructure
```bash
cd ../base
terraform output
gcloud container clusters list
kubectl get namespaces | grep datadog
```

### Step 2: Create terraform.tfvars (Optional)
```bash
cat > terraform.tfvars << 'EOF'
ctfd_user_password = "your-secure-password"
ctfd_secret_key = "your-secure-secret-key"
EOF
```

### Step 3: Deploy
```bash
terraform init
terraform plan
terraform apply
```

### Step 4: Verify Deployment
```bash
kubectl -n datadog get pods
kubectl -n default get pods
kubectl -n default get services
```

## Architecture Details

### Enhanced DatadogAgent
- Site: `ap1.datadoghq.com` (Asia Pacific)
- Namespace: `datadog`
- Features: APM, Log Collection, Container Security, Network Performance Monitoring

### Swagstore Microservices
12 microservices in `default` namespace:
1. adservice - Advertisement service
2. cartservice - Shopping cart service
3. checkoutservice - Checkout process service
4. currencyservice - Currency conversion service
5. emailservice - Email notification service
6. frontend - Web frontend service
7. loadgenerator - Load testing service
8. paymentservice - Payment processing service
9. productcatalogservice - Product catalog service
10. recommendationservice - Product recommendation service
11. redis - Redis cache service
12. shippingservice - Shipping calculation service

### Responseservice Microservice
Additional microservices and configurations in `default` namespace:
- **responseservice-v1** - Response handling service (version 1)
- **responseservice-v2** - Response handling service (version 2)
- **k6** - Load testing service for responseservice
- **k6-configmap** - Configuration for k6 load testing
- **configmap** - Configuration map for responseservice

## Troubleshooting

### Common Issues
1. **DatadogAgent Not Ready**: Verify base infrastructure is deployed
2. **Image Pull Errors**: Ensure GitHub Container Registry authentication is configured

### Useful Commands
```bash
# Check all pods in default namespace
kubectl -n default get pods -o wide

# Check responseservice pods specifically
kubectl -n default get pods -l app=responseservice

# Check k6 load testing pods
kubectl -n default get pods -l app=k6

# Check service logs
kubectl -n default logs -l app=frontend
kubectl -n default logs -l app=responseservice

# Port forward to access services
kubectl -n default port-forward svc/frontend 8080:80
kubectl -n default port-forward svc/responseservice 8081:80
```

## Cleanup
```bash
terraform destroy
```

## Next Steps
1. **Access the Application**: Use port-forwarding to access frontend and responseservice
2. **Generate Load**: Use the load generator or k6 for load testing
3. **Test Responseservice**: Access responseservice-v1 and responseservice-v2 endpoints
4. **Monitor**: View metrics, logs, and traces in Datadog
5. **Deploy CTFd**: Deploy the CTFd platform (`../ctfd/`) if needed

## Responseservice Testing

The responseservice includes load testing capabilities with k6:

```bash
# Check k6 configuration
kubectl -n default get configmap k6-configmap -o yaml

# Run k6 load tests
kubectl -n default exec -it deployment/k6 -- k6 run /scripts/loadtest.js

# Monitor responseservice performance
kubectl -n default logs -f deployment/responseservice-v1
kubectl -n default logs -f deployment/responseservice-v2
```
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
| <a name="provider_google"></a> [google](#provider\_google) | 6.28.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.5.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.38.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.datadog_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.responseservice](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.swagstore](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [http_http.responseservice_yaml_files](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [http_http.swagstore_yaml_files](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [terraform_remote_state.base](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | `"datadog-sandbox"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"asia-northeast1"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP zone | `string` | `"asia-northeast1-a"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->