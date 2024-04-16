// terraform-aws-modules/eks/aws: https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name = local.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access = true

  cluster_addons = {
    // クラスター内でサービス検出を有効にする
    coredns = {
      most_recent = true
    }
    // クラスター内でサービスネットワーキングを有効にする
    kube-proxy = {
      most_recent = true
    }
    // クラスター内でポッドネットワーキングを有効にする
    vpc-cni = {
      most_recent = true
    }
    // Kubernetes サービスアカウントを通じてポッドに AWS IAM アクセス許可を付与する
    eks-pod-identity-agent = {
      most_recent = true
    }
  }

  vpc_id = module.vpc.vpc_id

  // ノード/ノードグループがプロビジョニングされるサブネットIDのリスト
  // subnet_ids = concat(
  //   module.vpc.private_subnets,
  //   module.vpc.public_subnets,
  // )
  subnet_ids = module.vpc.private_subnets

  // マネージド型ノードグループ: https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/managed-node-groups.html
  eks_managed_node_group_defaults = {
    instance_types = ["t2.medium"]
  }

  eks_managed_node_groups = {
    group_01 = {
      min_size = 1
      max_size = 5
      desired_size   = 2
    }

    group_02 = {
      min_size = 1
      max_size = 5
      desired_size   = 1
      capacity_type = "SPOT"
    }
  }

  // クラスタ作成者(Terraformが使用するID)をアクセスエントリ経由で管理者として追加する
  enable_cluster_creator_admin_permissions = true

  // クラスターに対するIAMプリンシパルアクセスの有効化: https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/add-user-role.html
  authentication_mode = "API_AND_CONFIG_MAP"
}

// ~/.kube/configの自動生成
// kubeconfig ファイルを自動で作成する: https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/create-kubeconfig.html
resource "null_resource" "kubeconfig" {
  triggers = {
    cluster_name = module.eks.cluster_name
  }
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name}"
  }
  depends_on = [
    module.eks,
  ]
}

// Service accountsはPod内で動くプロセスのためのもの
// https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account
// FIXME: Post "http://localhost/api/v1/namespaces/kube-system/serviceaccounts": dial tcp 127.0.0.1:80: connect: connection refused で落ちる
/*
resource "kubernetes_service_account" "aws_loadbalancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_admin.iam_role_arn
    }
  }
  depends_on = [
    module.eks,
    null_resource.kubeconfig,
  ]
}
*/


data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
  depends_on = [
    module.eks,
    null_resource.kubeconfig
  ]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
  depends_on = [
    module.eks,
    null_resource.kubeconfig
  ]
}
