output "wafv2_rule_name" {
  value = aws_wafv2_web_acl.wafv2_app_acl.name
}

output "wafv2_rule_arn" {
  value = aws_wafv2_web_acl.wafv2_app_acl.arn
}
