resource "random_id" "secret_suffix" {
  byte_length = 3 # Genera ~6 caracteres hexadecimales
}

# Secret Manager para RDS
resource "aws_secretsmanager_secret" "rds_secret" {
  name        = "rds/${var.environment}/${local.rds_name}/v/${random_id.secret_suffix.hex}"
  description = "Credenciales para RDS"

  tags = merge(var.common_tags, {
    Name = "rds/${var.environment}/${local.rds_name}/v/${random_id.secret_suffix.hex}"
  })
}

resource "aws_secretsmanager_secret_version" "rds_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_secret.id
  secret_string = jsonencode({
    username = var.db_engine
    password = random_password.rds_password.result
    #host     = aws_db_instance.rds_instance.endpoint
    host     = aws_db_instance.rds_instance.address
    port     = aws_db_instance.rds_instance.port
    db_name  = var.db_engine
  })
}

resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "!#%&()+=?[]-_"
}

# Instancia de RDS
resource "aws_db_instance" "rds_instance" {
  identifier               = local.rds_name
  allocated_storage        = var.allocated_storage
  max_allocated_storage    = var.allocated_storage_max
  storage_type             = "gp3"
  engine                   = var.db_engine
  engine_version           = var.engine_version
  instance_class           = var.instance_class
  db_subnet_group_name     = var.subnet_group_name
  vpc_security_group_ids   = [var.security_group_id]
  username                 = var.db_engine
  password                 = random_password.rds_password.result
  backup_retention_period  = var.backup_retention_period
  delete_automated_backups = true
  publicly_accessible      = false
  skip_final_snapshot      = true
  deletion_protection      = false
  apply_immediately        = true
  storage_encrypted        = true

  tags = merge(var.common_tags, {
    Name = local.rds_name
  })
}

# Clave para usuario de base.
resource "random_password" "app_db_password" {
  length  = 16
  special = false
}

# Secret Manager para el usuario de app de RDS
resource "aws_secretsmanager_secret" "rds_app_secret" {
  name        = "app/${var.environment}/${var.project_name}/v/${random_id.secret_suffix.hex}"
  description = "Credenciales para usuario de RDS"

  tags = merge(var.common_tags, {
    Name = "app/${var.environment}/${var.project_name}/v/${random_id.secret_suffix.hex}"
  })
}

resource "aws_secretsmanager_secret_version" "rds_app_secret_version" {
  secret_id = aws_secretsmanager_secret.rds_app_secret.id
  secret_string = jsonencode({
    username = local.db_name
    password = random_password.app_db_password.result
    #host     = aws_db_instance.rds_instance.endpoint
    host     = aws_db_instance.rds_instance.address
    port     = aws_db_instance.rds_instance.port
    db_name  = local.db_name
  })
}

## Esta parte solo va a estar disponible si los runners son self-hosted dentro de la vpc o con acceso a ella.

##Crear DB
#provider "postgresql" {
#  alias = "rds"
#
#  host            = aws_db_instance.rds_instance.address
#  port            = aws_db_instance.rds_instance.port
#  username        = var.db_engine
#  password        = random_password.rds_password.result
#  sslmode         = "require"
#  connect_timeout = 15
#  superuser       = false
#}

#resource "time_sleep" "rds_wait" {
#  create_duration = "3m"
#  depends_on      = [aws_db_instance.rds_instance]
#}

#resource "postgresql_database" "app_db" {
#  provider = postgresql.rds
#
#  name              = local.db_name
#  owner             = var.db_engine
#  encoding          = "UTF8"
#  lc_collate        = "en_US.UTF-8"
#  lc_ctype          = "en_US.UTF-8"
#  template          = "template0"
#  connection_limit  = -1
#  allow_connections = true

#  depends_on = [time_sleep.rds_wait]
#}

## Crear usuario igual que el nombre de la base
#resource "postgresql_role" "app_user" {
#  provider = postgresql.rds

#  name     = local.db_name
#  login    = true
#  password = random_password.app_db_password.result
#}

# Otorgar privilegios
#resource "postgresql_grant" "app_user_privs" {
#  provider = postgresql.rds
#
#  database    = postgresql_database.app_db.name
#  role        = postgresql_role.app_user.name
#  object_type = "database"
#  privileges  = ["CONNECT", "TEMPORARY", "CREATE"]
#}

