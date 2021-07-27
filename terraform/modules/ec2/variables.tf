variable "namespace" { type = string }
variable "common_tags" { type = map(string) }
variable "vpc_id" { type = string }
variable "type" { type = string }

variable "egress_rules" {
  type    = list(any)
  default = null
}

variable "ingress_rules" {
  type    = list(any)
  default = null
}
variable "os_type" { default = "ubuntu" } #Ubuntu 18.04
variable "instance_type" { default = "t3.micro" }
variable "volume_size" { default = 10 }
variable "user_data" { default = null }
variable "monitoring" { default = true }
variable "ssh_keypairs_name" { type = string }
variable "subnet_id" { type = string }
variable "associate_pulic_ip" {
  type    = bool
  default = false
}
variable "iam_policy_contents" {
  type    = string
  default = ""

  //usage: iam_policy_contents = file("ec2-policy.json")
}
variable "set_static_ami" {
  type    = bool
  default = false
}
variable "static_ami" { default = "" }
