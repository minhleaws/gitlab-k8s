output "gitlab_runner_cache_bucket_name" {
  value = aws_s3_bucket.gitlab-runner-cache.bucket
}
output "gitlab_runner_cache_bucket_arn" {
  value = aws_s3_bucket.gitlab-runner-cache.arn
}

output "gitlab_backups_bucket_name" {
  value = aws_s3_bucket.gitlab-backups.bucket
}
output "gitlab_backups_bucket_arn" {
  value = aws_s3_bucket.gitlab-backups.arn
}

output "gitlab_tmp_bucket_name" {
  value = aws_s3_bucket.gitlab-tmp.bucket
}
output "gitlab_tmp_bucket_arn" {
  value = aws_s3_bucket.gitlab-tmp.arn
}

output "gitlab_pseudo_bucket_name" {
  value = aws_s3_bucket.gitlab-pseudo.bucket
}
output "gitlab_pseudo_bucket_arn" {
  value = aws_s3_bucket.gitlab-pseudo.arn
}

output "gitlab_lfs_bucket_name" {
  value = aws_s3_bucket.git-lfs.bucket
}
output "gitlab_lfs_bucket_arn" {
  value = aws_s3_bucket.git-lfs.arn
}

output "gitlab_artifacts_bucket_name" {
  value = aws_s3_bucket.gitlab-artifacts.bucket
}
output "gitlab_artifacts_bucket_arn" {
  value = aws_s3_bucket.gitlab-artifacts.arn
}

output "gitlab_uploads_bucket_name" {
  value = aws_s3_bucket.gitlab-uploads.bucket
}
output "gitlab_uploads_bucket_arn" {
  value = aws_s3_bucket.gitlab-uploads.arn
}

output "gitlab_packages_bucket_name" {
  value = aws_s3_bucket.gitlab-packages.bucket
}
output "gitlab_packages_bucket_arn" {
  value = aws_s3_bucket.gitlab-packages.arn
}

output "gitlab_mr_diffs_bucket_name" {
  value = aws_s3_bucket.gitlab-mr-diffs.bucket
}
output "gitlab_mr_diffs_bucket_arn" {
  value = aws_s3_bucket.gitlab-mr-diffs.arn
}

output "gitlab_terraform_state_bucket_name" {
  value = aws_s3_bucket.gitlab-terraform-state.bucket
}
output "gitlab_terraform_state_bucket_arn" {
  value = aws_s3_bucket.gitlab-terraform-state.arn
}

output "gitlab_dependency_proxy_bucket_name" {
  value = aws_s3_bucket.gitlab-dependency-proxy.bucket
}
output "gitlab_dependency_proxy_bucket_arn" {
  value = aws_s3_bucket.gitlab-dependency-proxy.arn
}

output "gitlab_pages_bucket_name" {
  value = aws_s3_bucket.gitlab-pages.bucket
}
output "gitlab_pages_bucket_arn" {
  value = aws_s3_bucket.gitlab-pages.arn
}

output "gitlab_registry_bucket_name" {
  value = aws_s3_bucket.gitlab-registry.bucket
}
output "gitlab_registry_bucket_arn" {
  value = aws_s3_bucket.gitlab-registry.arn
}
