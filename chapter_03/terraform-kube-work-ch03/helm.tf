// AWS Load Balancer Controller - Helmを使用してインストールする
// https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/lbc-helm.html
resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  // 最新バージョン: https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
  version    = "1.7.2"
  namespace  = "kube-system"
  depends_on = [
    kubernetes_service_account.aws_loadbalancer_controller,
    null_resource.kubeconfig
  ]

  set {
    name  = "clusterName"
    value = data.aws_eks_cluster.eks.name
  }

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.ap-northeast-1.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    // 最新バージョン: https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
    name  = "image.tag"
    value = "v2.7.2"
  }
}