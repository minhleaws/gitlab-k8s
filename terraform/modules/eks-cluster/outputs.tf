output "endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "oidc_url" {
  value = aws_iam_openid_connect_provider.main.url
}

output "oidc_arn" {
  value = aws_iam_openid_connect_provider.main.arn
}
