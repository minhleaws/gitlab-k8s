variable "namespace" { type = string }
variable "common_tags" { type = map(string) }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "egress_rules" {
  type    = list(any)
  default = []
}
variable "ingress_rules" {
  type    = list(any)
  default = []
}

variable "eks_version" { default = "1.18" }
variable "authorized_source_ranges" { type = list(string) }

