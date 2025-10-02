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
3. **⚠️ CRITICAL: ServiceAccount configuration completed** - You must have run the kubectl patch command from the base module's Step 5
4. GitHub access to `dd-japan/ctf-swagstore` repository

### Verify ServiceAccount Configuration

Before deploying this module, verify that the default ServiceAccount has been properly configured for GitHub Container Registry access:

```bash
# Check if imagePullSecrets is configured
kubectl get serviceaccount default -n default -o yaml | grep -A 5 imagePullSecrets

# Expected output should show:
# imagePullSecrets:
# - name: ghcr-secret
```

If the above command shows no output or missing `imagePullSecrets`, you must complete the base module's Step 5 first:

```bash
cd ../base
terraform output instruction
# Run the kubectl patch command from the output
```

## Required Variables

This module has no variables. All configuration is handled through the base module's remote state and hardcoded values in the locals block.

## Deployment Steps

### Step 1: Verify Base Infrastructure and ServiceAccount Configuration
```bash
cd ../base
terraform output
gcloud container clusters list
kubectl get namespaces | grep datadog

# ⚠️ CRITICAL: Verify ServiceAccount configuration
kubectl get serviceaccount default -n default -o yaml | grep -A 5 imagePullSecrets
```

**Expected output should include:**
```yaml
imagePullSecrets:
- name: ghcr-secret
```

**If imagePullSecrets is missing, run:**
```bash
terraform output instruction
# Execute the kubectl patch command from the output
```

### Step 2: Deploy
```bash
terraform init
terraform plan
terraform apply
```

### Step 3: Verify Deployment
```bash
kubectl -n datadog get pods
kubectl -n default get pods
kubectl -n default get services
```

## Architecture Details

This module fetches Kubernetes manifests directly from GitHub repositories and deploys them.

### Enhanced DatadogAgent
- **Site**: `ap1.datadoghq.com` (Asia Pacific)
- **Namespace**: `datadog`
- **Features**: APM, Log Collection, Container Security, Network Performance Monitoring
- **Source**: `datadog-agent.yaml` (local template file)

### Swagstore Microservices
**Source**: `https://github.com/dd-japan/ctf-swagstore` (2025-1H branch)

12 microservices deployed to `default` namespace:

1. **adservice** - Advertisement service
2. **cartservice** - Shopping cart service
3. **checkoutservice** - Checkout processing service
4. **currencyservice** - Currency conversion service
5. **emailservice** - Email notification service
6. **frontend** - Web frontend service
7. **loadgenerator** - Load testing service
8. **paymentservice** - Payment processing service
9. **productcatalogservice** - Product catalog service
10. **recommendationservice** - Product recommendation service
11. **redis** - Redis cache service
12. **shippingservice** - Shipping calculation service

### Responseservice Microservices
**Source**: `https://github.com/dd-japan/ctf-swagstore/responseservice/` (2025-1H branch)

Additional microservices and configurations deployed to `default` namespace:

- **responseservice-v1** - Response handling service (version 1)
- **responseservice-v2** - Response handling service (version 2)
- **k6** - Load testing service for responseservice
- **k6-configmap** - Configuration for k6 load testing
- **configmap** - Configuration map for responseservice

### Deployment Method
- **HTTP Data Sources**: Uses Terraform HTTP data sources to fetch YAML files directly from GitHub
- **Dynamic Manifest Processing**: Uses `provider::kubernetes::manifest_decode_multi` to process multi-document YAML
- **Namespace Override**: Forces all resources to be deployed in the `default` namespace

## Troubleshooting

### Common Issues

1. **DatadogAgent Not Ready**: Verify base infrastructure is deployed

2. **Image Pull Errors (ImagePullBackOff/ErrImagePull)**
   ```
   Error: Failed to pull image "ghcr.io/dd-japan/ctf-swagstore/..."
   ```
   **Solution**: This is usually caused by missing ServiceAccount configuration. Verify that the base module's Step 5 was completed:
   ```bash
   kubectl get serviceaccount default -n default -o yaml | grep imagePullSecrets
   ```
   If missing, run the kubectl patch command from the base module.

3. **GitHub Container Registry Authentication Failed**
   ```
   Error: 403 Forbidden when pulling from ghcr.io
   ```
   **Solution**: Ensure GitHub Container Registry authentication is configured and ServiceAccount is properly patched.

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

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->