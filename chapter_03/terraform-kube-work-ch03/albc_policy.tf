/**
 * AWS Load Balancer ControllerがALBを作成するために必要なPolicy/Roleを作成します。
 * このRoleをContorollerが使用することにより、Ingressリソースが作成された際に自動でALBを作成できます。
 */

resource "aws_iam_policy" "aws_loadbalancer_controller" {
  name   = "${local.project_name}-EKSIngressAWSLoadBalancerControllerPolicy"
  policy = file("${path.module}/albc_iam_policy.json")
}

// OpenID Connect Federated Usersを使用して信頼されたリソースが引き受けることができるIAMロールを作成
// https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-assumable-role-with-oidc
module "iam_assumable_role_admin" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "~> 5.39.0"

  create_role                  = true
  role_name                    = "${local.project_name}-EKSIngressAWSLoadBalancerControllerRole"
  provider_url                 = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns             = [aws_iam_policy.aws_loadbalancer_controller.arn]
  oidc_subjects_with_wildcards = ["system:serviceaccount:*:*"]
}