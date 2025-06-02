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
- **トリガー**: PR の作成時
- **実行内容**:
  - aquaproj/aqua-installer を使用して trivy をインストール
  - 以下のセキュリティスキャンを実行:
    - リポジトリの設定ファイルのスキャン
    - 依存関係の脆弱性スキャン
    - コンテナイメージのスキャン（存在する場合）
  - スキャン結果を PR にコメント
  - 重大な脆弱性が検出された場合はワークフローを失敗させる

### 🏗️ Terraform Plan/Apply
- **ファイル**: 
  - Plan: `.github/workflows/plan.yaml`
  - Apply: `.github/workflows/apply-base.yaml`, `.github/workflows/apply.yaml`
- **トリガー**: 
  - Plan: PR の作成時
  - Apply: PR に対して `/apply` をコメント時
- **実行内容**:
  - Google Cloud Platform への認証
  - aquaproj/aqua-installer を使用して必要なツールをインストール
  - Terraform の初期化とフォーマットチェック
  - Terraform の構文チェック
  - Terraform の plan/apply 実行
  - tfcmt を使用して実行結果を PR にコメント
  - Plan 実行時は変更内容に応じて以下のラベルを付与:
    - `add-or-update`: リソースの追加・更新時
    - `destroy`: リソースの削除時
    - `no-changes`: 変更なし
  - エラー発生時は詳細なエラーメッセージと対処方法を表示

### 🔄 Renovate
- **設定ファイル**: `.github/renovate.json5`
- **実行内容**:
  - 依存関係の自動更新
  - 以下のスケジュールで実行: 午前1時から9時の間
  - 更新タイプに応じた安定化期間:
    - メジャーバージョン: 7日
    - マイナーバージョン: 2日
    - パッチバージョン: 1日
  - 脆弱性アラートの監視と通知
  - PR の作成制限:
    - 1時間あたり5件まで
    - 同時実行3件まで

## ⚠️ 注意事項
- ワークフローの実行には適切な権限設定が必要です
- Terraform の実行には Google Cloud Platform の認証情報が必要です
- Renovate の設定は必要に応じて調整可能です
- Terraform の plan は PR を作成し、.tf 配下に差分があると自動的に実行されますが、重要な変更の場合は手動での確認も可能です（Github コンソール上から実行）
- セキュリティスキャンで検出された脆弱性は優先的に対応することを推奨します
- PR のラベルは自動的に付与されますが、手動で変更することも可能です
- ラベルの付与は以下の条件で制御されます:
  - `add-or-update`: Terraform の plan でリソースの追加または更新が検出された場合
  - `destroy`: Terraform の plan でリソースの削除が検出された場合
  - `no-changes`: Terraform の plan で変更が検出されなかった場合
  - 既存のラベルは新しい plan 実行時に自動的に更新されます
