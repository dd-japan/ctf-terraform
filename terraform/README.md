<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.12.1 |
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 6.28.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.28.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_iam_workload_identity_pool.github_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.github_provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_service_account_iam_member.workload_identity_account_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_storage_bucket.test_bucket_japan](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_service_account.terraform_sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enabled_services"></a> [enabled\_services](#input\_enabled\_services) | n/a | <pre>map(list(object({<br/>    log_type         = string<br/>    exempted_members = optional(list(string))<br/>  })))</pre> | <pre>{<br/>  "storage.googleapis.com": [<br/>    {<br/>      "log_type": "DATA_READ"<br/>    },<br/>    {<br/>      "log_type": "DATA_WRITE"<br/>    },<br/>    {<br/>      "log_type": "ADMIN_READ"<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | 環境に関するvariable | `string` | `"dev"` | no |
| <a name="input_github_org"></a> [github\_org](#input\_github\_org) | n/a | `string` | `"dd-japan"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ################################################################################# Workload Identity Poolに関するvariable ################################################################################# Projectに関するvariable | `string` | `"datadog-sandbox"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"asia-northeast1"` | no |
| <a name="input_repo_name"></a> [repo\_name](#input\_repo\_name) | n/a | `string` | `"ctf-terraform"` | no |
| <a name="input_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#input\_tfstate\_bucket\_name) | backendに関するvariable | `string` | `"ctf-terraform-tfstate"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->