terraform {
  required_version = "~> 1.8.0"

  backend "s3" {
    bucket = "kubernetes-work-tfstate"
    key    = "kubernetes-work/chapter3/01/terraform.tfstate"
    region = "ap-northeast-1"
    encrypt = true
  }

  required_providers {
    // AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.45.0"
    }
    // Kubernetes Provider: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29.0"
    }
    // Helm Provider: https://registry.terraform.io/providers/hashicorp/helm/latest/docs
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      PROJECT = "KUBERNETES_WORK_CHAPTER03",
    }
  }
}

locals {
  cluster_name = "kubernetes-work-chapter03"
}

/**
 * provider "kubernetes" {
 *   config_path    = "~/.kube/config"
 *   config_context = local.project_name
 * }
 */

/*
provider "kubernetes" {
  // kubenetesAPIのホスト名(URL形式)。KUBE_HOST環境変数で指定している値に基づく。
  host                   = var.cluster_endpoint
  // TLS認証用のPEMエンコードされたルート証明書のバンドル
  cluster_ca_certificate = base64decode(var.cluster_ca_cert)
  // Exec plugins: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#exec-plugins
  // ユーザークレデンシャルを受け取るためのコマンド
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}
*/


/*
provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca_cert)
    // Exec plugins: https://registry.terraform.io/providers/hashicorp/helm/latest/docs#exec-plugins
    // ユーザークレデンシャルを受け取るためのコマンド
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
      command     = "aws"
    }
  }
}
*/