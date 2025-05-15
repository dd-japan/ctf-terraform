# Datadog Agent & Swagstore Kubernetes Manifests (via Terraform)

このTerraform構成は、以下をGoogle Kubernetes Engine (GKE) クラスタにデプロイするためのものです：

- Datadog Agent（CRDマニフェスト使用）
- Swagstore アプリケーション（マニフェスト）

> 🚧 **WIP（Work In Progress）**
>
> - Datadog Agentの **CRDマニフェストファイルの更新作業が未完了** です。
> - `common_name` に関する処理も未実装または改修が残っています。
>
> 本番適用する場合は、これらの変更が完了しているかを確認してください。

---

## 🔧 必要条件

- Terraform v1.10 以上
- GCP プロジェクトと対応するクレデンシャル
- GKE クラスタが既に構築されている（Remote State を参照）

---

## 🚀 デプロイ手順（概要）

1. `terraform.tfvars` に必要な変数（例：`project_id`, `region`）を記述します。
2. 初期化と適用：

```bash
terraform init
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
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.36.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_manifest.datadog_agent](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [kubernetes_manifest.swagstore](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) | resource |
| [google_client_config.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [http_http.yaml_files](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [terraform_remote_state.k8s](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID for your GCP project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region | `string` | `"asia-northeast1"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP zone | `string` | `"asia-northeast1-a"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->