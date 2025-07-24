output "vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "private_subnet_rds_id" {
  value = aws_subnet.subnet_private_rds[*].id
}

output "private_subnet_id" {
  value = aws_subnet.subnet_private[*].id
}

output "public_subnet_id" {
  value = aws_subnet.subnet_public[*].id
}

output "security_group_rds_id" {
  value = aws_security_group.vpc_rds_sg.id
}

output "subnet_group_rds_id" {
  value = aws_db_subnet_group.rds_sngn.id
}

output "subnet_group_rds_name" {
  value = aws_db_subnet_group.rds_sngn.name
}

output "security_group_id" {
  value = aws_security_group.vpc_rds_ec2_lambda.id
}

output "security_group_alb_id" {
  value = aws_security_group.alb_sg.id
}

