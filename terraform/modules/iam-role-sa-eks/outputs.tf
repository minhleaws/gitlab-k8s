data "template_file" "secret" {
  template = aws_iam_access_key.main.secret
}

output "iam_secret_key" {
  value = data.template_file.secret.rendered
}

output "iam_access_key" {
  value = aws_iam_access_key.main.id
}