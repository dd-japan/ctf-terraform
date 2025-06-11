#------------------------------------------------------------------------------
# VPC
#------------------------------------------------------------------------------

data "google_client_config" "default" {}

resource "random_pet" "primary" {
  length = 1
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "10.0.0"

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
      name          = "allow-custom-ingress-${local.common_name}"
      description   = "Allow ingress from specific IP to certain ports"
      priority      = 1000
      source_ranges = var.allowed_ips
      allow = [
        {
          protocol = "tcp"
          ports    = ["22", "80", "443", "6443", "8080", "8888"]
        }
      ]
      target_tags = ["ctf"]
    },
    {
      name          = "allow-custom-ingress-same-vpc-${local.common_name}"
      description   = "Allow ingress from same VPC"
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
      name          = "allow-nodeport-ingress-${local.common_name}"
      description   = "Allow ingress to node ports"
      priority      = 1000
      source_ranges = var.allowed_ips
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
      name               = "allow-all-egress-${local.common_name}"
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
  service_account = data.google_service_account.terraform_sa.email

  # クラスタのバージョンやその他の設定
  release_channel = var.gke_release_channel
}

#------------------------------------------------------------------------------
# Datadog Operator
#------------------------------------------------------------------------------

resource "kubernetes_secret" "datadog_api" {
  metadata {
    name      = "datadog-secret"
    namespace = "default"
  }

  data = {
    apikey = var.dd_api_key
  }

  type = "Opaque"

  depends_on = [module.gke]
}

resource "helm_release" "datadog_operator" {
  name       = "datadog-operator"
  chart      = "datadog-operator"
  repository = "https://helm.datadoghq.com"
  namespace  = "default"

  depends_on = [
    kubernetes_secret.datadog_api
  ]
}