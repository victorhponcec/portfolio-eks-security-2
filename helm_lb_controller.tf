resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.14.0" #update
  set = [
    {
      name  = "clusterName"
      value = aws_eks_cluster.security.name
    },

    {
      name  = "region"
      value = var.region1
    },

    {
      name  = "vpcId"
      value = aws_vpc.main.id
    },

    #Helm will not to create a new ServiceAccount
    {
      name  = "serviceAccount.create"
      value = "false"
    },

    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },

    #link ServiceAccount with your IAM role for IRSA
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.alb_controller.arn
    }
  ]
  depends_on = [
    aws_iam_role.alb_controller,
    aws_iam_role_policy_attachment.alb_controller_attach,
    aws_iam_openid_connect_provider.eks,
    aws_eks_cluster.security,
    aws_eks_access_entry.admin, #test1
    aws_eks_access_entry.admin, #test2 FIXED DEPENDENCY CREATION ORDER
    #aws_eks_access_policy_association.admin, #test3
  ]
}
### test
data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.security.name
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.security.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
