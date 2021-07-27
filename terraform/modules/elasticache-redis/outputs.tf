output "aws_elasticache_subnet_group" {
  value = aws_elasticache_subnet_group.main.name
}

output "aws_elasticache_parameter_group" {
  value = aws_elasticache_parameter_group.main.name
}

output "aws_security_group" {
  value = aws_security_group.main.name
}

output "primary_endpoint_address" {
  value = aws_elasticache_replication_group.main.primary_endpoint_address
}