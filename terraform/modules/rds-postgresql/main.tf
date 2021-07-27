# ---------------------------------------------------------------------------------------------------------------------
# RDS - Postgresql
# ---------------------------------------------------------------------------------------------------------------------
#1. Create subnet group
resource "aws_db_subnet_group" "main" {
  name        = "${var.namespace}-postgresql-subnet-group"
  description = "${var.namespace} - rds postgresql subnet group"
  subnet_ids  = var.subnet_ids
}

#2. Create parameter group
resource "aws_db_parameter_group" "main" {
  name        = "${var.namespace}-posgresql-parameter-group"
  family      = var.family
  description = "${var.namespace} - rds posgresql parameter group"
}

#3. Create security group
resource "aws_security_group" "main" {
  name        = "${var.namespace}-rds-posgresql-sg"
  vpc_id      = var.vpc_id
  description = "${var.namespace} - rds redis security group"

  tags = merge(
    { Name = "${var.namespace}-rds-posgresql-sg" },
    var.common_tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  egress_rules = {
    for x in var.egress_rules : "${x.id}" => x
  }

  ingress_rules = {
    for x in var.ingress_rules : "${x.id}" => x
  }
}

resource "aws_security_group_rule" "egress" {
  for_each = local.egress_rules

  security_group_id = aws_security_group.main.id

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

resource "aws_security_group_rule" "ingress" {
  for_each = local.ingress_rules

  security_group_id = aws_security_group.main.id

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

#4. Create PostgreSQL DB Instance
resource "aws_db_instance" "postgresql" {

  # type
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  # storage
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true

  # credential
  identifier = "${var.namespace}-postgresql-db-instance"
  port       = 5432
  name       = var.db_name
  username   = var.db_username
  password   = var.db_password

  # parameter Group, subnet group & security groups 
  parameter_group_name   = aws_db_parameter_group.main.name
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.main.id]

  # backup & maintenance 
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  # ha
  multi_az = var.multi_az

  # extend
  apply_immediately               = true
  copy_tags_to_snapshot           = true
  auto_minor_version_upgrade      = false
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  skip_final_snapshot             = true

  tags = merge(
    { Name = "${var.namespace}-postgresql-db-instance" },
    var.common_tags,
  )
}
