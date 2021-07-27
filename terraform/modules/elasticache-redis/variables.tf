variable "namespace" { type = string }
variable "common_tags" { type = map(string) }

variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }

variable "family" { default = "redis5.0" }
variable "node_type" { default = "cache.t3.small" }
variable "number_cache_clusters" { default = 1 }
variable "engine_version" { default = "5.0.6" }
variable "maintenance_window" { default = "sun:16:00-sun:17:00" }
variable "snapshot_window" { default = "17:01-18:01" }
variable "snapshot_retention_limit" { default = 7 }

variable "automatic_failover_enabled" { default = false }
variable "multi_az_enabled" { default = false }

variable "egress_rules" {
  type    = any
  default = null
}
variable "ingress_rules" {
  type    = any
  default = null
}