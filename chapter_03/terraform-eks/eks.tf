// EKSクラスターの作成
// https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.4.0"
  cluster_version = "1.25"
  cluster_name    = "eks-cluster"
  vpc_id          = var.vpc_id
  #vpc_id      = module.vpc.vpc_id
  subnet_ids      = var.private_subnets
  #subnet_ids      = module.vpc.private_subnets
  enable_irsa     = true
  // KESのNodeGroupsには "Managed" と "Self Managed" の2つのタイプがある。
  // "Managed" はNodeのプロビジョニングとライフサイクル管理をEKSが自動で行う。
  eks_managed_node_groups = {
    eks_node_group = {
      desired_size   = 2
      instance_types = ["t2.medium"]
    }
  }

  // Clusterに追加のセキュリティグループを設定
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  // Nodeに追加のセキュリティグループを設定
  node_security_group_additional_rules = {

    admission_webhook = {
      description                   = "Admission Webhook"
      protocol                      = "tcp"
      from_port                     = 0
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

resource "null_resource" "kubeconfig" {
  triggers = {
    cluster_name = module.eks.cluster_id
  }
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${module.eks.cluster_name}"
  }
}


resource "kubernetes_service_account" "aws_loadbalancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_assumable_role_admin.iam_role_arn
    }
  }
}


data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
  depends_on = [ 
    module.eks
  ]
}

data "aws_eks_cluster_auth" "eks" {
  name = module.eks.cluster_name
  depends_on = [ 
    module.eks
  ]
}
