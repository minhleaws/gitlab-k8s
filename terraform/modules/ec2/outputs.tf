output "instance_id" {
  value = aws_instance.ec2_instance.id
}

output "instance_arn" {
  value = aws_instance.ec2_instance.arn
}

output "public_ip" {
  value = var.associate_pulic_ip == true ? aws_eip.ec2_instance[0].public_ip : ""
}

output "public_dns" {
  value = var.associate_pulic_ip == true ? aws_eip.ec2_instance[0].public_dns : ""
}

output "private_dns" {
  value = aws_instance.ec2_instance.private_dns
}

output "private_ip" {
  value = aws_instance.ec2_instance.private_ip
}

output "security_group_id" {
  value = aws_security_group.ec2_instance.id
}

output "subnet_id" {
  value = aws_instance.ec2_instance.subnet_id
}
