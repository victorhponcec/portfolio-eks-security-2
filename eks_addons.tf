#check this--------------------------
resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.security.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.20.4-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.security.name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.34.0-eksbuild.4"
  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.security.name
  addon_name                  = "coredns"
  addon_version               = "v1.12.4-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}

/*check latest ADD-ON versions:
# VPC CNI plugin
aws eks describe-addon-versions --addon-name vpc-cni --kubernetes-version 1.34
# kube-proxy
aws eks describe-addon-versions --addon-name kube-proxy --kubernetes-version 1.34
# CoreDNS
aws eks describe-addon-versions --addon-name coredns --kubernetes-version 1.34
*/