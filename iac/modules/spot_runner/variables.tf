variable "region" {
  description = "Región de AWS"
  type        = string
}

variable "project_name" {
  description = "Nombre de la VPC existente"
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

variable "github_runner_secret_name" {
  description = "Token Github Runner"
  type        = string
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
}

variable "subnet_id" {
  description = "subnet id List"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security groups id List"
  type        = list(string)
}