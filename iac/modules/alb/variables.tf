variable "region" {
  description = "Región de AWS"
  type        = string
}

variable "project_name" {
  description = "Name of project used by created all resources names"
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

variable "certificate_ssl" {
  description = "ARN del certificado SSL en AWS No sé si armar yo el arn o colocarlo completo"
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

variable "vpc_id" {
  description = "vpc id"
  type        = string
}