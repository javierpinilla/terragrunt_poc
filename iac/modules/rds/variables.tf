variable "region" {
  description = "Región de AWS"
  type        = string
}

variable "project_name" {
  description = "Nombre de la VPC"
  type        = string
}

variable "common_tags" {
  description = "Etiquetas comunes para recursos"
  type        = map(string)
}

variable "environment" {
  description = "Entorno"
  type        = string
}

variable "subnet_group_name" {
  description = "Name of subnet group"
  type        = string
}

variable "security_group_id" {
  description = "Security groups id List"
  type        = string
}

variable "backup_retention_period" {
  description = "Days of backup retention"
  type        = number
  default     = 7
}

variable "allocated_storage" {
  description = "Size allocate storage in GB"
  type        = number
  default     = 20
}

variable "allocated_storage_max" {
  description = "Max size allocate storage in GB"
  type        = number
  default     = 30
}

variable "engine_version" {
  description = "Version of engine"
  type        = string
  default     = "17.5"
}

variable "instance_class" {
  description = "Instance type"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_engine" {
  description = "DB instance engine (postgres, mysql, etc)"
  type        = string
  default     = "postgres"
}