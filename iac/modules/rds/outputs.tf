output "rds_endpoint" {
  description = "Endpoint rds"
  value       = aws_db_instance.rds_instance.endpoint
}

output "rds_secret_arn" {
  description = "ARN Secret Rds"
  value       = aws_secretsmanager_secret.rds_secret.arn
}

output "rds_app_secret_arn" {
  description = "ARN App Secret Rds"
  value       = aws_secretsmanager_secret.rds_app_secret.arn
}