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

variable "instance_type" {
  description = "Instance Type"
  type        = string
}

variable "app_secret_name" {
  description = "Apps secrets"
  type        = string
}

variable "subnet_id" {
  description = "subnet id List"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security groups id List"
  type        = string
}

variable "target_group_arn" {
  description = "arn target group"
  type        = string
}

variable "host_header" {
  description = "Url by to rule of listener 443"
  type        = string
}

variable "alb_arn" {
  description = "Arn of ALB"
  type        = string
}

variable "alb_prioriry_rules" {
  description = "Number priority to alb rules"
  type        = number
}