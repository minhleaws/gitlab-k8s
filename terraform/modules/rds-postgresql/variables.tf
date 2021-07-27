variable "namespace" { type = string }
variable "common_tags" { type = map(string) }

variable "family" { default = "postgres12" }

variable "egress_rules" {
  type    = any
  default = null
}
variable "ingress_rules" {
  type    = any
  default = null
}

variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }

variable "engine_version" { default = "12.5" }
variable "instance_class" { default = "db.t3.micro" }
variable "storage_type" { default = "gp2" }
variable "allocated_storage" { default = 30 }       #GB
variable "max_allocated_storage" { default = 1000 } #1TB
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string }
variable "backup_retention_period" { default = 30 }               #days
variable "backup_window" { default = "00:00-02:00" }              #UTC
variable "maintenance_window" { default = "sat:03:00-sat:06:00" } #UTC
variable "multi_az" {
  type    = bool
  default = false
}
