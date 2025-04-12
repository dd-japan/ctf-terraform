#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------

data "google_client_config" "default" {}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 10.0.0"

  project_id   = var.project_id
  network_name = "${local.common_name}-network"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "${local.common_name}-subnet-a"
      subnet_ip             = "10.10.1.0/24"
      subnet_region         = var.region
      subnet_private_access = true
      subnet_flow_logs      = false
    },
    {
      subnet_name           = "${local.common_name}-subnet-b"
      subnet_ip             = "10.10.2.0/24"
      subnet_region         = var.region
      subnet_private_access = true
      subnet_flow_logs      = false
    },
    {
      subnet_name           = "${local.common_name}-subnet-c"
      subnet_ip             = "10.10.3.0/24"
      subnet_region         = var.region
      subnet_private_access = true
      subnet_flow_logs      = false
    },
    {
      subnet_name           = "${local.common_name}-gke-subnet-a"
      subnet_ip             = "10.10.0.0/24"
      subnet_region         = var.region
      subnet_private_access = true
      subnet_flow_logs      = false
    }
  ]

  secondary_ranges = {
    "${local.common_name}-gke-subnet-a" = [
      {
        range_name    = "pod-range"
        ip_cidr_range = "10.20.0.0/14"
      },
      {
        range_name    = "svc-range"
        ip_cidr_range = "10.24.0.0/20"
      }
    ]
  }

  ingress_rules = [
    {
      name          = "allow-custom-ingress-ctf-infra"
      description   = "Allow ingress from specific IP to certain ports"
      priority      = 1000
      source_ranges = [var.allowed_ip1, var.allowed_ip2]
      allow = [
        {
          protocol = "tcp"
          ports    = ["22", "80", "443", "6443", "8080", "8888"]
        }
      ]
      target_tags = ["ctf"]
    },
    {
      name          = "allow-custom-ingress"
      description   = "Allow ingress from specific IP to certain ports"
      priority      = 1000
      source_ranges = ["10.10.0.0/16"]
      allow = [
        {
          protocol = "all"
        }
      ]
      target_tags = ["ctf"]
    },
    {
      name          = "allow-nodeport-ingress"
      description   = "Allow ingress to node ports"
      priority      = 1000
      source_ranges = [var.allowed_ip1, var.allowed_ip2]
      allow = [
        {
          protocol = "tcp"
          ports    = ["30000-32767"]
        }
      ]
      target_tags = ["ctf"]
    }
  ]

  egress_rules = [
    {
      name               = "allow-all-egress-ctf-infra"
      description        = "Allow all outbound traffic for ctf-infra"
      priority           = 1000
      destination_ranges = ["0.0.0.0/0"]
      allow = [
        {
          protocol = "all"
        }
      ]
      target_tags = ["ctf"]
    }
  ]
}

#------------------------------------------------------------------------------
# SSH key pair
#------------------------------------------------------------------------------

resource "tls_private_key" "ctf_infra_common" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ctf_infra_common.private_key_pem
  filename        = pathexpand("~/ctf_infra_bastion_key")
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = tls_private_key.ctf_infra_common.public_key_openssh
  filename        = pathexpand("~/ctf_infra_bastion_key.pub")
  file_permission = "0600"
}

#------------------------------------------------------------------------------
# Get Ubuntu 22.04 LTS image
#------------------------------------------------------------------------------

data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

#------------------------------------------------------------------------------
# IAM configuration
#------------------------------------------------------------------------------

data "google_service_account" "ctf_infra" {
  account_id = var.sa_email
}

#------------------------------------------------------------------------------
# Bastion configuration
#------------------------------------------------------------------------------

resource "google_compute_address" "bastion" {
  name    = "${local.common_name}-bastion-ip"
  region  = var.region
  project = var.project_id
}

resource "google_compute_instance" "bastion" {
  name                      = "${local.common_name}-bastion"
  machine_type              = var.machine_type
  zone                      = var.zone
  project                   = var.project_id
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = 100
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = module.vpc.subnets_self_links[0]

    access_config {
      nat_ip = google_compute_address.bastion.address
    }
  }

  metadata = {
    ssh-keys = "ubuntu:${tls_private_key.ctf_infra_common.public_key_openssh}"
  }

  labels = local.common_tags

  service_account {
    email  = data.google_service_account.ctf_infra.email
    scopes = ["cloud-platform"]
  }

  tags = ["ctf"]

  metadata_startup_script = templatefile("${path.module}/bastion.sh", {
    COMMON_PUBLIC_KEY  = tls_private_key.ctf_infra_common.public_key_openssh
    COMMON_PRIVATE_KEY = tls_private_key.ctf_infra_common.private_key_openssh
    GKE_CLUSTER_NAME   = module.gke.name
    GKE_CLUSTER_REGION = var.region
    GCP_PROJECT_ID     = var.project_id
  })

  depends_on = [module.gke]
}

#------------------------------------------------------------------------------
# GKE
#------------------------------------------------------------------------------

module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "~> 36.0.2"

  project_id        = var.project_id
  name              = "${local.common_name}-gke-cluster"
  region            = var.region
  network           = module.vpc.network_name
  subnetwork        = module.vpc.subnets_names[0]
  ip_range_pods     = "pod-range"
  ip_range_services = "svc-range"
  network_tags      = ["ctf"]

  regional = true # リージョンベースのクラスタ

  grant_registry_access  = false
  create_service_account = false

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = var.gke_node_type
      node_locations     = var.zones
      min_count          = 1
      max_count          = 3
      disk_size_gb       = 30
      disk_type          = "pd-standard"
      preemptible        = false
      initial_node_count = 1
      auto_upgrade       = true
      auto_repair        = true
    },
  ]

  node_pools_tags = {
    all = ["ctf"]
  }

  deletion_protection = false

  # サービスアカウントの設定
  service_account = data.google_service_account.ctf_infra.email

  # クラスタのバージョンやその他の設定
  release_channel = var.gke_release_channel
}

#------------------------------------------------------------------------------
# Kubernetes resources
#------------------------------------------------------------------------------

resource "kubernetes_secret" "datadog_api" {
  metadata {
    name      = "datadog-secret"
    namespace = "default"
  }

  data = {
    api-key = var.dd_api_key
  }

  type = "Opaque"

  depends_on = [module.gke]
}

resource "helm_release" "datadog_agent" {
  name       = "datadog-agent"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  namespace  = "default"
  values     = [file("${path.module}/datadog-values.yaml")]

  depends_on = [
    module.gke,
    kubernetes_secret.datadog_api
  ]
}