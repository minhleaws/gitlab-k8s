# ---------------------------------------------------------------------------------------------------------------------
# Elasticache - Redis
# ---------------------------------------------------------------------------------------------------------------------

#1. Create subnet group
resource "aws_elasticache_subnet_group" "main" {
  name        = "${var.namespace}-redis-subnet-group"
  description = "${var.namespace} - elasticache redis subnet group"
  subnet_ids  = var.subnet_ids
}

#2. Create parameter group
resource "aws_elasticache_parameter_group" "main" {
  name        = "${var.namespace}-redis-parameter-group"
  family      = var.family
  description = "${var.namespace} - elasticache redis parameter group"
}

#3. Create security group
resource "aws_security_group" "main" {
  name        = "${var.namespace}-elasticache-redis-sg"
  vpc_id      = var.vpc_id
  description = "${var.namespace} - elasticache redis security group"

  tags = merge(
    { Name = "${var.namespace}-elasticache-redis-sg" },
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
  ///

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

#4. Create replication group
resource "aws_elasticache_replication_group" "main" {
  replication_group_id          = "${var.namespace}-redis-repl-group"
  replication_group_description = "${var.namespace} - elasticache redis replication group"

  parameter_group_name = aws_elasticache_parameter_group.main.name
  subnet_group_name    = aws_elasticache_subnet_group.main.name
  security_group_ids   = [aws_security_group.main.id]

  engine         = "redis"
  engine_version = var.engine_version

  node_type             = var.node_type
  number_cache_clusters = var.number_cache_clusters

  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled           = var.multi_az_enabled

  maintenance_window       = var.maintenance_window
  snapshot_window          = var.snapshot_window
  snapshot_retention_limit = var.snapshot_retention_limit

  apply_immediately          = true
  auto_minor_version_upgrade = false
  port                       = 6379


  tags = merge(
    { Name = "${var.namespace}-redis-repl-group" },
    var.common_tags,
  )
}
