# ---------------------------------------------------------------------------------------------------------------------
# SG
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "ec2_instance" {
  name        = "${var.namespace}-${var.type}-instance-sg"
  vpc_id      = var.vpc_id
  description = "EC2 Instance security group"

  tags = merge(
    { Name = "${var.namespace}-${var.type}-instance-sg" },
    { type = var.type },
    var.common_tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# SG Rules
# ---------------------------------------------------------------------------------------------------------------------

locals {
  egress_rules = {
    for x in var.egress_rules : "${x.id}" => x
  }
  ///

  ingress_rules = {
    for x in var.ingress_rules : "${x.id}" => x
  }
}

/// EGRESS
resource "aws_security_group_rule" "egress" {
  for_each = local.egress_rules

  security_group_id = aws_security_group.ec2_instance.id

  type                     = "egress"
  description              = each.value.description
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  from_port                = each.value.from_port
  to_port                  = each.value.to_port

  lifecycle {
    create_before_destroy = true
  }
}

/// INGRESS
resource "aws_security_group_rule" "ingress" {
  for_each = local.ingress_rules

  security_group_id = aws_security_group.ec2_instance.id

  type                     = "ingress"
  description              = each.value.description
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  from_port                = each.value.from_port
  to_port                  = each.value.to_port

  lifecycle {
    create_before_destroy = true
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------------------------------------------------------

# 1. IAM Assume Role
data "aws_iam_policy_document" "ec2_instance" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# 2. IAM Role
resource "aws_iam_role" "ec2_instance" {
  name               = "${var.namespace}-${var.type}-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_instance.json
  description        = "EC2 Instance IAM Role"

  tags = merge(
    { Name = "${var.namespace}-${var.type}-instance-role" },
    var.common_tags,
  )
}

# 3. IAM Policy
data "template_file" "ec2_instance" {
  template = file("template/policy-ec2-instance-general.json")
}

resource "aws_iam_role_policy" "ec2_instance" {
  name   = "${var.namespace}-${var.type}-instance-policy"
  role   = aws_iam_role.ec2_instance.id
  policy = coalesce(var.iam_policy_contents, data.template_file.ec2_instance.rendered)
}

# 4. Instance Profile
resource "aws_iam_instance_profile" "ec2_instance" {
  name = "${var.namespace}-${var.type}-instance-profile"
  role = aws_iam_role.ec2_instance.name
}


# ---------------------------------------------------------------------------------------------------------------------
# EC2 Instance
# ---------------------------------------------------------------------------------------------------------------------
locals {
  ami_supported = {
    ubuntu  = join("", data.aws_ami.ubuntu_1804[*].id) # convert list to string
    amzn2   = join("", data.aws_ami.amzn2[*].id)
    default = join("", data.aws_ami.default[*].id)
  }

  ami_id = lookup(local.ami_supported, var.os_type, local.ami_supported["default"])
}

resource "aws_instance" "ec2_instance" {
  ami = var.set_static_ami == true ? var.static_ami : local.ami_id

  instance_type = var.instance_type
  key_name      = var.ssh_keypairs_name

  vpc_security_group_ids = [aws_security_group.ec2_instance.id]
  subnet_id              = var.subnet_id
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance.id

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.volume_size
    delete_on_termination = true
  }
  credit_specification {
    cpu_credits = "standard"
  }

  disable_api_termination = false
  user_data               = var.user_data
  monitoring              = var.monitoring

  tags = merge(
    { Name = "${var.namespace}-${var.type}-instance" },
    { type = var.type },
    var.common_tags
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip" "ec2_instance" {
  count = var.associate_pulic_ip == true ? 1 : 0

  vpc      = true
  instance = aws_instance.ec2_instance.id

  tags = merge(
    { Name = "${var.namespace}-${var.type}-instance-eip" },
    { type = var.type },
    var.common_tags,
  )
}
