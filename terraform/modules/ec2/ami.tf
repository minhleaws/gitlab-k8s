# Ubuntu 18.04
data "aws_ami" "ubuntu_1804" {
  count = var.os_type == "ubuntu" ? 1 : 0

  most_recent = true
  owners      = ["099720109477"] #Ubuntu

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-*"]
  }
}

# Amazone Linux 2
data "aws_ami" "amzn2" {
  count = var.os_type == "amzn2" ? 1 : 0

  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}

# Default Amazone Linux 2
data "aws_ami" "default" {
  count = var.os_type != "amzn2" || var.os_type != "ubuntu" ? 1 : 0

  most_recent = true
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}
