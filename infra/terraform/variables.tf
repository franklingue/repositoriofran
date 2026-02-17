variable "project_name" {
  description = "Nombre lógico del proyecto"
  type        = string
  default     = "mercadoecuador"
}

variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Dominio raíz (apex) del sitio"
  type        = string
  default     = "mercadoecuador.com.ec"
}

variable "subdomain" {
  description = "Subdominio para el sitio"
  type        = string
  default     = "www"
}

variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs de las subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs de las subnets privadas"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para PHP"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "Nombre de la key pair para acceso SSH (opcional)"
  type        = string
  default     = null
}

variable "asg_min_size" {
  type    = number
  default = 2
}

variable "asg_desired_capacity" {
  type    = number
  default = 2
}

variable "asg_max_size" {
  type    = number
  default = 4
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "mercado"
}

variable "db_username" {
  type    = string
  default = "appuser"
}

variable "db_multi_az" {
  type    = bool
  default = true
}

variable "allowed_http_cidrs" {
  description = "CIDRs permitidos para acceder al ALB por HTTP/HTTPS"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "nuvei_secret_name" {
  description = "Nombre del secreto de Secrets Manager para Nuvei"
  type        = string
  default     = "nuvei/credentials"
}

variable "db_secret_name" {
  description = "Nombre del secreto para credenciales de DB"
  type        = string
  default     = "db/credentials"
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs permitidos para acceder por SSH al bastion"
  type        = list(string)
  default     = ["203.0.113.10/32", "198.51.100.22/32"]
}

variable "bastion_instance_type" {
  description = "Tipo de instancia para el bastion"
  type        = string
  default     = "t3.micro"
}

variable "bastion_enabled" {
  description = "Habilita el bastion host"
  type        = bool
  default     = true
}
