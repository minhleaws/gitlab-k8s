resource "aws_wafv2_web_acl" "wafv2_app_acl" {
  name        = "${var.namespace}-${var.type}-wafv2-app-acl"
  description = "${var.namespace}-${var.type}-wafv2-app-acl"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Define rule
  dynamic "rule" {
    for_each = var.wafv2_acl_rule
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = "AWS"
          dynamic "excluded_rule" {
            for_each = try(rule.value.excluded_rule, [])
            content {
              name = excluded_rule.value
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = rule.value.name
        sampled_requests_enabled   = true
      }
    }
  }

  tags = merge(
    { Name = "${var.namespace}-${var.type}-wafv2-app-acl" },
    var.common_tags,
  )


  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.namespace}-${var.type}-wafv2-app-acl-metric"
    sampled_requests_enabled   = true
  }

}
