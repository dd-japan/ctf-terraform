<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->

# GitHub Actions ワークフロー一覧

このディレクトリには、Terraform関連の自動化・CI/CDワークフローが格納されています。

## ワークフロー一覧

### 1. ベース（terraform/ 直下）用
- **apply.yaml**
  - PRコメントで`/apply`と入力すると、terraform/直下のリソースに対して`terraform apply`を実行します。
- **plan.yaml**
  - PRでterraform/直下の`.tf`ファイルが変更された場合、自動で`terraform plan`を実行します。
- **plan-dispatch.yaml**
  - 手動トリガー（workflow_dispatch）でterraform/直下の`terraform plan`を実行します。
- **destroy-dispatch.yaml**
  - 手動トリガー（workflow_dispatch）でterraform/直下の`terraform destroy`を実行します。

### 2. アドオン（terraform/addon/）用
- **apply-addon.yaml**
  - PRコメントで`/apply-addon`と入力すると、terraform/addon配下のリソースに対して`terraform apply`を実行します。
- **plan-addon.yaml**
  - PRでterraform/addon配下の`.tf`ファイルが変更された場合、自動で`terraform plan`を実行します。
- **plan-dispatch-addon.yaml**
  - 手動トリガー（workflow_dispatch）でterraform/addon配下の`terraform plan`を実行します。
- **destroy-dispatch-addon.yaml**
  - 手動トリガー（workflow_dispatch）でterraform/addon配下の`terraform destroy`を実行します。

### 3. その他
- **apply-base.yaml / apply-base-addon.yaml**
  - 上記apply系ワークフローから呼び出される共通処理定義です。
- **terraform-docs.yaml**
  - terraform-docsによるドキュメント自動生成用ワークフローです。
- **trivy.yaml**
  - Trivyによるセキュリティスキャン用ワークフローです。
- **actionlint.yaml**
  - GitHub ActionsのYAML構文チェック用ワークフローです。

---

各ワークフローの詳細なトリガーや処理内容は、各YAMLファイルの冒頭コメントや`on:`セクションを参照してください。