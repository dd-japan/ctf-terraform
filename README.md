# 🔄 GitHub Actions Workflows

このリポジトリでは以下の GitHub Actions ワークフローが実行されます。

## 📋 ワークフロー一覧

### 🛠️ Lint GitHub Actions workflows
- **ファイル**: `.github/workflows/actionlint.yaml`
- **トリガー**: `.github/workflows/*.yaml` が変更された PR
- **実行内容**: 
  - aquaproj/aqua-installer を使用して actionlint をインストール
  - GitHub Actions のワークフローファイルの構文チェックを実行

### 🔍 Trivy Security Scan
- **ファイル**: `.github/workflows/trivy.yaml`
- **トリガー**: `terraform/*.tf` が変更された PR
- **実行内容**:
  - aquasecurity/trivy-action を使用してセキュリティスキャンを実行
  - 設定ファイルの脆弱性スキャン（HIGH, CRITICAL レベルのみ）
  - スキャン結果を PR にスティッキーコメントとして投稿
  - 脆弱性が検出されない場合は「脆弱性が検知されませんでした」と表示

### 📚 Terraform Documentation Generation
- **ファイル**: `.github/workflows/terraform-docs.yaml`
- **トリガー**: `terraform/**.tf` が変更された PR
- **実行内容**:
  - terraform-docs/gh-actions を使用してドキュメントを自動生成
  - `./terraform/README.md` にドキュメントを注入
  - 変更を自動的にコミット・プッシュ

### 🏗️ Terraform Plan (Base Resources)
- **ファイル**: `.github/workflows/plan-base.yaml`
- **トリガー**: `terraform/**/*.tf` が変更された PR（`terraform/**/README.md` を除く）
- **実行内容**:
  - Google Cloud Platform への認証
  - aquaproj/aqua-installer を使用して必要なツールをインストール
  - Terraform の初期化とフォーマットチェック
  - Terraform の構文チェック
  - Terraform の plan 実行（`./terraform` ディレクトリ）
  - tfcmt を使用して実行結果を PR にコメント
  - 変更内容に応じて以下のラベルを自動付与:
    - `add-or-update`: リソースの追加・更新時
    - `destroy`: リソースの削除時
    - `no-changes`: 変更なし

### 🏗️ Terraform Plan (Addon Resources)
- **ファイル**: `.github/workflows/plan-addon.yaml`
- **トリガー**: `terraform/addon/**/*.tf` が変更された PR（`terraform/addon/**/README.md` を除く）
- **実行内容**:
  - Google Cloud Platform への認証
  - aquaproj/aqua-installer を使用して必要なツールをインストール
  - Terraform の初期化とフォーマットチェック
  - Terraform の構文チェック
  - Terraform の plan 実行（`./terraform/addon` ディレクトリ）
  - tfcmt を使用して実行結果を PR にコメント
  - 変更内容に応じてラベルを自動付与

### 🚀 Terraform Apply (Base Resources)
- **ファイル**: `.github/workflows/apply-base.yaml`
- **トリガー**: 他のワークフローから呼び出し（`workflow_call`）
- **入力パラメータ**:
  - `working_dir`: Terraform 実行ディレクトリ
  - `project_id`: 対象の Google Cloud プロジェクト ID
- **実行内容**:
  - Google Cloud Platform への認証
  - aquaproj/aqua-installer を使用して必要なツールをインストール
  - Terraform の初期化とフォーマットチェック
  - Terraform の構文チェック
  - Terraform の apply 実行
  - tfcmt を使用して実行結果を PR にコメント
  - 同時実行制御（concurrency）により、同じ環境への重複実行を防止

### 🚀 Terraform Apply (Addon Resources)
- **ファイル**: `.github/workflows/apply-addon.yaml`
- **トリガー**: 他のワークフローから呼び出し（`workflow_call`）
- **入力パラメータ**:
  - `working_dir`: Terraform 実行ディレクトリ
  - `project_id`: 対象の Google Cloud プロジェクト ID
- **実行内容**:
  - Google Cloud Platform への認証
  - aquaproj/aqua-installer を使用して必要なツールをインストール
  - Terraform の初期化とフォーマットチェック
  - Terraform の構文チェック
  - Terraform の apply 実行
  - tfcmt を使用して実行結果を PR にコメント
  - 同時実行制御（concurrency）により、同じ環境への重複実行を防止

### 🔧 Manual Terraform Apply (Base Resources)
- **ファイル**: `.github/workflows/apply1.yaml`
- **トリガー**: PR に `/apply` コメントが投稿された時
- **実行内容**:
  - `apply-base.yaml` ワークフローを呼び出し
  - `./terraform` ディレクトリで base リソースの apply を実行

### 🔧 Manual Terraform Apply (Addon Resources)
- **ファイル**: `.github/workflows/apply2.yaml`
- **トリガー**: PR に `/apply-addon` コメントが投稿された時
- **実行内容**:
  - `apply-addon.yaml` ワークフローを呼び出し
  - `./terraform/addon` ディレクトリで addon リソースの apply を実行

### 🎯 Manual Terraform Plan (Base Resources)
- **ファイル**: `.github/workflows/plan-base-dispatch.yaml`
- **トリガー**: 手動実行（`workflow_dispatch`）
- **入力パラメータ**:
  - `project`: 対象プロジェクト（datadog-sandbox）
- **実行内容**:
  - Google Cloud Platform への認証
  - aquaproj/aqua-installer を使用して必要なツールをインストール
  - Terraform の初期化とフォーマットチェック
  - Terraform の構文チェック
  - Terraform の plan 実行（`./terraform` ディレクトリ）
  - tfcmt を使用して実行結果をコメント

### 🎯 Manual Terraform Plan (Addon Resources)
- **ファイル**: `.github/workflows/plan-addon-dispatch.yaml`
- **トリガー**: 手動実行（`workflow_dispatch`）
- **入力パラメータ**:
  - `project`: 対象プロジェクト（datadog-sandbox）
- **実行内容**:
  - Google Cloud Platform への認証
  - aquaproj/aqua-installer を使用して必要なツールをインストール
  - Terraform の初期化とフォーマットチェック
  - Terraform の構文チェック
  - Terraform の plan 実行（`./terraform/addon` ディレクトリ）
  - tfcmt を使用して実行結果をコメント

### 🎯 Manual Terraform Apply (Base Resources)
- **ファイル**: `.github/workflows/apply-base-dispatch.yaml`
- **トリガー**: 手動実行（`workflow_dispatch`）
- **入力パラメータ**:
  - `project`: 対象プロジェクト（datadog-sandbox）
- **実行内容**:
  - Google Cloud Platform への認証
  - aquaproj/aqua-installer を使用して必要なツールをインストール
  - Terraform の初期化とフォーマットチェック
  - Terraform の構文チェック
  - Terraform の apply 実行（`./terraform` ディレクトリ）
  - tfcmt を使用して実行結果をコメント

### 🎯 Manual Terraform Apply (Addon Resources)
- **ファイル**: `.github/workflows/apply-addon-dispatch.yaml`
- **トリガー**: 手動実行（`workflow_dispatch`）
- **入力パラメータ**:
  - `project`: 対象プロジェクト（datadog-sandbox）
- **実行内容**:
  - Google Cloud Platform への認証
  - aquaproj/aqua-installer を使用して必要なツールをインストール
  - Terraform の初期化とフォーマットチェック
  - Terraform の構文チェック
  - Terraform の apply 実行（`./terraform/addon` ディレクトリ）
  - tfcmt を使用して実行結果をコメント

### 🗑️ Manual Terraform Destroy (Base Resources)
- **ファイル**: `.github/workflows/destroy-base-dispatch.yaml`
- **トリガー**: 手動実行（`workflow_dispatch`）
- **入力パラメータ**:
  - `project`: 対象プロジェクト（datadog-sandbox）
- **実行内容**:
  - Google Cloud Platform への認証
  - Terraform の destroy 実行（`./terraform` ディレクトリ）
  - tfcmt を使用して実行結果をコメント

### 🗑️ Manual Terraform Destroy (Addon Resources)
- **ファイル**: `.github/workflows/destroy-addon-dispatch.yaml`
- **トリガー**: 手動実行（`workflow_dispatch`）
- **入力パラメータ**:
  - `project`: 対象プロジェクト（datadog-sandbox）
- **実行内容**:
  - Google Cloud Platform への認証
  - Terraform の destroy 実行（`./terraform/addon` ディレクトリ）
  - tfcmt を使用して実行結果をコメント

## 🚀 使用方法

### 自動実行ワークフロー
1. **Plan 実行**: PR を作成すると、Terraform ファイルの変更に応じて自動的に plan が実行されます
2. **Apply 実行**: PR に以下のコメントを投稿することで apply を実行できます：
   - `/apply`: base リソースの apply
   - `/apply-addon`: addon リソースの apply

### 手動実行ワークフロー
1. GitHub リポジトリの **Actions** タブに移動
2. 実行したいワークフローを選択
3. **Run workflow** ボタンをクリック
4. 必要に応じてパラメータを設定
5. **Run workflow** をクリックして実行

### 利用可能な手動実行ワークフロー
- **Plan 実行**:
  - `terraform plan dispatch for base`: base リソースの plan
  - `terraform plan dispatch for addon`: addon リソースの plan
- **Apply 実行**:
  - `terraform apply dispatch for base`: base リソースの apply
  - `terraform apply dispatch for addon`: addon リソースの apply
- **Destroy 実行**:
  - `terraform destroy dispatch for base`: base リソースの destroy
  - `terraform destroy dispatch for addon`: addon リソースの destroy

## ⚠️ 注意事項
- ワークフローの実行には適切な権限設定が必要です
- Terraform の実行には Google Cloud Platform の認証情報が必要です
- 重要な変更の場合は手動での確認も可能です（GitHub コンソール上から実行）
- セキュリティスキャンで検出された脆弱性は優先的に対応することを推奨します
- PR のラベルは自動的に付与されますが、手動で変更することも可能です
- ラベルの付与は以下の条件で制御されます:
  - `add-or-update`: Terraform の plan でリソースの追加または更新が検出された場合
  - `destroy`: Terraform の plan でリソースの削除が検出された場合
  - `no-changes`: Terraform の plan で変更が検出されなかった場合
  - 既存のラベルは新しい plan 実行時に自動的に更新されます
- 同時実行制御により、同じ環境への重複実行は防止されます
- Terraform の state lock の仕組みは、Job が強制停止時にロックが解除できなくなる可能性があるため使用していません

## 🔧 必要な環境変数・シークレット
以下の GitHub Secrets が設定されている必要があります：
- `ALLOWED_IPS`: 許可された IP アドレス
- `DD_API_KEY`: Datadog API キー
- `CTFD_SECRET_KEY`: CTFd シークレットキー
- `GITHUB_TOKEN`: GitHub トークン（自動設定）

## 📁 ディレクトリ構造
- `./terraform/`: base リソース用の Terraform ファイル
- `./terraform/addon/`: addon リソース用の Terraform ファイル
