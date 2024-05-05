data "aws_iam_policy_document" "secrets_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" 
      values   = ["system:serviceaccount:default:utility-cluster-aws-secrets-dev"] // namespace where sa will be use
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws-secrets" {
  //the policy define with data is like a template for easy use we pass it here to create the policy
  assume_role_policy = data.aws_iam_policy_document.secrets_assume_role_policy.json
  name               = "aws-secrets-${var.environment}"
}

//---------------------policy to use secrets manager-------------------------

resource "aws_iam_policy" "eks_csi_driver_policy" {
  name        = "${var.project_name}-secrets-pol-${var.environment}"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        /*you need to specify the arn of the secret you want to use in the app if you need
        more than one you can use a comma and if you need them all you can use
        arn:aws:secretsmanager:*:*:secret:*(not tested)*/
        Resource = ["arn:aws:secretsmanager:us-east-1:438555236323:secret:gradle-app-secrets-vZLOZT"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws-secrets_attach_secrets" {
  role       = aws_iam_role.aws-secrets.name
  policy_arn = aws_iam_policy.eks_csi_driver_policy.arn
}

resource "kubernetes_service_account" "secrets_controller_sa" {
  metadata {
    name      = "utility-cluster-aws-secrets-dev"
    namespace = "default" // where is the app that uses this sa

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws-secrets.arn
    }
  }

  depends_on = [
    aws_eks_node_group.private-nodes
  ]
}

resource "helm_release" "secrets-store-csi-driver" {
  name       = "${var.project_name}-csi-secrets-store-${var.environment}"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  version    = "1.2.4"

  namespace = "kube-system"
  set {
    name  = "enableSecretRotation"
    value = "true"
  }

  set {
    name  = "syncSecret.enabled"
    value = "true"
  }

  depends_on = [aws_eks_node_group.private-nodes]
  
}

resource "helm_release" "secrets-store-csi-driver-provider-aws" {
  name       = "${var.project_name}-secrets-provider-${var.environment}"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  version    = "0.1.0"

  namespace = "kube-system"

  set {
    name  = "region"
    value = "us-east-1"
  }

  depends_on = [aws_eks_node_group.private-nodes]

}