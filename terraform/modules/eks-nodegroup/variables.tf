variable "namespace" { type = string }
variable "common_tags" { type = map(string) }
variable "eks_cluster_name" { type = string }
variable "nodegroup_name" { type = string }
variable "subnet_ids" { type = list(string) }
variable "desired_size" { default = 1 }
variable "max_size" { default = 1 }
variable "min_size" { default = 1 }
variable "instance_types" { default = "t3.medium" }
variable "ami_type" { default = "AL2_x86_64" }
variable "capacity_type" { default = "ON_DEMAND" }
variable "disk_size" { default = 20 }
variable "ssh_keypairs" { type = string }