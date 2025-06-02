# GitHub Actions Workflows

このリポジトリでは以下のGitHub Actionsワークフローが実行されます。

## ワークフロー一覧

### Lint GitHub Actions workflows
- **ファイル**: `.github/workflows/actionlint.yaml`
- **トリガー**: `.github/workflows/*.yaml` が変更されたPR
- **実行内容**: 
  - aquaproj/aqua-installerを使用してactionlintをインストール
  - GitHub Actionsのワークフローファイルの構文チェックを実行

### Trivy Security Scan
- **ファイル**: `.github/workflows/trivy.yaml`
- **トリガー**: PRの作成時
- **実行内容**:
  - aquaproj/aqua-installerを使用してtrivyをインストール
  - 以下のセキュリティスキャンを実行:
    - リポジトリの設定ファイルのスキャン
    - 依存関係の脆弱性スキャン
    - コンテナイメージのスキャン（存在する場合）
  - スキャン結果をPRにコメント
  - 重大な脆弱性が検出された場合はワークフローを失敗させる

### Terraform Plan
- **ファイル**: `.github/workflows/plan.yaml`
- **トリガー**: PRの作成時
- **実行内容**:
  - Google Cloud Platformへの認証
  - aquaproj/aqua-installerを使用して必要なツールをインストール
  - Terraformの初期化とフォーマットチェック
  - Terraformの構文チェック
  - Terraformのplan実行
  - tfcmtを使用して実行結果をPRにコメント
  - 変更内容に応じて以下のラベルを付与:
    - `add-or-update`: リソースの追加・更新時
    - `destroy`: リソースの削除時
    - `no-changes`: 変更なし
  - エラー発生時は詳細なエラーメッセージを表示

### Terraform Apply
- **ファイル**: `.github/workflows/apply-base.yaml`,`.github/workflows/apply.yaml`
- **トリガー**: PRに対して、 `/apply` をコメント時
- **実行内容**:
  - Google Cloud Platformへの認証
  - aquaproj/aqua-installerを使用して必要なツールをインストール
  - Terraformの初期化
  - Terraformの構文チェック
  - Terraformのapply実行
  - tfcmtを使用して実行結果をPRにコメント
  - エラー発生時は詳細なエラーメッセージと対処方法を表示

### Renovate
- **設定ファイル**: `.github/renovate.json5`
- **実行内容**:
  - 依存関係の自動更新
  - 以下のスケジュールで実行: 午前1時から9時の間
  - 更新タイプに応じた安定化期間:
    - メジャーバージョン: 7日
    - マイナーバージョン: 2日
    - パッチバージョン: 1日
  - 脆弱性アラートの監視と通知
  - PRの作成制限:
    - 1時間あたり5件まで
    - 同時実行3件まで

## 注意事項
- ワークフローの実行には適切な権限設定が必要です
- Terraformの実行にはGoogle Cloud Platformの認証情報が必要です
- Renovateの設定は必要に応じて調整可能です
- Terraformのplan/applyは自動的に実行されますが、重要な変更の場合は手動での確認を推奨します
- セキュリティスキャンで検出された脆弱性は優先的に対応することを推奨します
