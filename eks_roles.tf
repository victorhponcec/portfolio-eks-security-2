#IAM policy for the AWS Load Balancer Controller
#AWS for installation of LB controller with heml: https://docs.aws.amazon.com/eks/latest/userguide/lbc-helm.html
#curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json

data "http" "alb_iam_policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.14.1/docs/install/iam_policy.json"
}

resource "aws_iam_policy" "alb_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for the AWS Load Balancer Controller"
  policy      = data.http.alb_iam_policy.response_body
}

resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

resource "aws_iam_role" "alb_controller" {
  name = "eks-alb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

#OIDC identity provider
data "aws_eks_cluster" "security" {
  name = aws_eks_cluster.security.name
}
data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.security.identity[0].oidc[0].issuer
}
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.security.identity[0].oidc[0].issuer
}

#Create Kubernetes ServiceAccount and link AWS IAM role via IRSA
resource "kubernetes_service_account" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
  depends_on = [
    #aws_eks_cluster.security, #delete this = breaks addon order
    aws_eks_access_entry.admin
  ] #test1
}

########## 
/*
provider "kubernetes" {
  host                   = aws_eks_cluster.security.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.security.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.security.token
}
data "aws_eks_cluster_auth" "security" {
  name = aws_eks_cluster.security.name
}
*/