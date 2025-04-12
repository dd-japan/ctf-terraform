# 🛠️ GCP Infrastructure with GKE, Bastion Host, and Datadog Monitoring (via Terraform)

This repository contains Terraform code to provision a complete Google Cloud Platform (GCP) infrastructure stack, including:

- VPC network with custom subnets and firewall rules
- Bastion host (Ubuntu 22.04)
- Regional GKE cluster (Google Kubernetes Engine)
- Datadog Agent deployment using Helm
- Secure SSH key pair generation
- Automatic deployment of the [Swagstore demo app](https://github.com/dd-japan/ctf-swagstore)

---

## 📦 Architecture Overview

- **VPC**: Custom VPC with four subnets and secondary IP ranges for GKE
- **Firewall**: Ingress rules for SSH, HTTP/HTTPS, NodePort, etc.
- **Bastion**: Public VM instance to securely access internal resources
- **GKE Cluster**: Regional, autoscaling-enabled, with proper network tags
- **Kubernetes Provider**: Used with `helm_release` and `kubernetes_secret`
- **Datadog Agent**: Installed via Helm chart with a user-provided API key

---

## 🧱 Requirements

- Terraform >= 1.10
- GCP Project
- A service account with IAM permissions for GKE, Compute, IAM, etc.
- [Datadog API Key](https://docs.datadoghq.com/ja/account_management/api-app-keys/)

---

## 🔐 Setup

### 1. Create a `terraform.tfvars` file with the following:

```hcl
project_id          = "your-gcp-project-id"
region              = "asia-northeast1"
zone                = "asia-northeast1-a"
common_name         = "ctf-infra"
gke_node_type       = "e2-medium"
zones               = ["asia-northeast1-a", "asia-northeast1-b", "asia-northeast1-c"]
gke_release_channel = "REGULAR"
sa_email            = "your-service-account-name"
allowed_ip1         = "your-home-ip/32"
allowed_ip2         = "your-office-ip/32"
dd_api_key          = "your-datadog-api-key"
```

### 2. Initialize and apply

```bash
terraform init
terraform apply
```

### 3. 🔑 SSH Access

```bash
ssh -i ~/ctf_infra_bastion_key -o IdentitiesOnly=yes ubuntu@<Bastion IP>
```

### 4. ☁️ Kubernetes Access (from Bastion)

```bash
# Wait for startup tasks to complete
tail -f /var/log/user-data.log

# Check Datadog agent status
kubectl exec -n default <datadog-agent-pod-name> -c agent -- agent status
```

## 🧹 Clean Up

Before destroying the Terraform stack, delete Kubernetes apps:

```bash
kubectl delete -k /home/ubuntu/ctf-swagstore/kustomize/
kubectl -n default get all
```

Then:

```bash
terraform destroy
```

## 📁 Files and Structure

- `main.tf`: Core infrastructure definition
- `outputs.tf`: Useful outputs including SSH and GKE info
- `datadog-values.yaml`: Helm values for Datadog agent
- `bastion.sh`: Bastion startup script (Kubernetes tools, GKE setup)

## 🧠 Notes

- GKE node pool tags are managed via `node_pools_tags = { all = ["ctf"] }` to ensure firewall rules apply.
- SSH keys and Kubernetes access are automatically configured during bastion startup.
- Ensure your IP is allowed in `allowed_ip1` or `allowed_ip2` for firewall access.

## 📎 References

- [Terraform GCP Network Module](https://github.com/terraform-google-modules/terraform-google-network)
- [Terraform GCP GKE Module](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine)
- [Datadog Helm Chart](https://github.com/DataDog/helm-charts)

## 🛡️ Security Tips

- Do not commit `terraform.tfvars` or your private SSH key
- Rotate Datadog API keys regularly
- Use Secret Manager or Vault for managing sensitive variables

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
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gke"></a> [gke](#module\_gke) | terraform-google-modules/kubernetes-engine/google | ~> 36.0.2 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-google-modules/network/google | ~> 10.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.bastion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_instance.bastion](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [helm_release.datadog_agent](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_secret.datadog_api](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [local_file.private_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.public_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.ctf_infra_common](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_image.ubuntu](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
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
| <a name="output_bastion_global_ip"></a> [bastion\_global\_ip](#output\_bastion\_global\_ip) | The public (global) IP of the bastion server |
| <a name="output_bastion_private_ip"></a> [bastion\_private\_ip](#output\_bastion\_private\_ip) | The private IP of the bastion server |
| <a name="output_common_private_key_openssh"></a> [common\_private\_key\_openssh](#output\_common\_private\_key\_openssh) | value of the private key in OpenSSH format |
| <a name="output_common_public_key_openssh"></a> [common\_public\_key\_openssh](#output\_common\_public\_key\_openssh) | value of the public key in OpenSSH format |
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