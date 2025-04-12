#! /bin/bash -e

set -e

exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

#------------------------------------------------------------------------------
# Configure ssh key
#------------------------------------------------------------------------------

echo "${COMMON_PUBLIC_KEY}" >> /home/ubuntu/.ssh/authorized_keys
echo "${COMMON_PRIVATE_KEY}" > /home/ubuntu/.ssh/id_rsa
chmod 600 /home/ubuntu/.ssh/id_rsa
chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa

#------------------------------------------------------------------------------
# Tools installation
#------------------------------------------------------------------------------

echo "必要なツールのインストールを開始します。"

sudo apt-get update && \
  sudo apt-get install wget gpg coreutils gnupg lsb-release apt-transport-https ca-certificates curl software-properties-common git awscli unzip acl net-tools -y

echo "必要なツールのインストールが完了しました。"
echo ""

#------------------------------------------------------------------------------
# Google Cloud SDK
#------------------------------------------------------------------------------

echo "Google Cloud SDKのインストールを開始します。"

sudo apt-get update

# 古い GPG キーを削除し、新しいキーを取得
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# GCP の公式リポジトリを追加
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# パッケージリストを更新 & Google Cloud SDK をインストール
sudo apt-get update && sudo apt-get install -y google-cloud-cli

# gcloud コマンドの初期設定
echo "export PATH=\$PATH:/usr/lib/google-cloud-sdk/bin" >> /home/ubuntu/.bashrc
source /home/ubuntu/.bashrc

echo "Google Cloud SDKのインストールが完了しました。"
echo ""

#------------------------------------------------------------------------------
# Docker installation
#------------------------------------------------------------------------------

echo "Dockerをインストールします。"

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo usermod -a -G docker ubuntu

echo "Dockerのインストールが完了しました。"
echo ""

#------------------------------------------------------------------------------
# Deploy Swagstore demo application
#------------------------------------------------------------------------------

# https://github.com/dd-japan/ctf-swagstore/tree/main
echo "Swagstoreのデモアプリケーションをセットアップします。"

cd /home/ubuntu/
git clone https://github.com/dd-japan/ctf-swagstore.git
chown -R ubuntu:ubuntu /home/ubuntu/ctf-swagstore
cd /home/ubuntu/ctf-swagstore

# frontend-external Service にアノテーションを追加
#sed -i '/name: frontend-external/a\  annotations:\n    cloud.google.com/neg: '\''{"ingress": false}'\''' /home/ubuntu/ctf-swagstore/kustomize/base/frontend.yaml

# kubectl セットアップ
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list 
sudo apt-get update
sudo apt-get install -y kubectl

echo 'source <(kubectl completion bash)' >>/home/ubuntu/.bashrc
echo 'alias k=kubectl' >>/home/ubuntu/.bashrc
echo 'complete -o default -F __start_kubectl k' >>/home/ubuntu/.bashrc

# GKE接続
sudo apt-get install google-cloud-cli-gke-gcloud-auth-plugin -y
echo "実行コマンド:gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --region ${GKE_CLUSTER_REGION} --project ${GCP_PROJECT_ID}"
sudo -u ubuntu -i gcloud container clusters get-credentials "${GKE_CLUSTER_NAME}" \
  --region "${GKE_CLUSTER_REGION}" \
  --project "${GCP_PROJECT_ID}"

chown -R ubuntu:ubuntu /home/ubuntu/.kube

sudo -u ubuntu -i kubectl apply -k /home/ubuntu/ctf-swagstore/kustomize/

echo "Swagstoreのデモアプリケーションのセットアップが完了しました。"