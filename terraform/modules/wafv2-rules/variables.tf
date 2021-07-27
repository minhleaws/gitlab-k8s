variable "namespace" { type = string }
variable "common_tags" { type = map(string) }
variable "type" { type = string }
variable "wafv2_acl_rule" { type = any }
