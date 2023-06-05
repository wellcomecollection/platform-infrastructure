variable "namespace" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "efs_id" {
  type = string
}
variable "efs_security_group_id" {
  type = string
}
variable "ec_privatelink_security_group_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

# Grafana
variable "grafana_version" {
  type = string
}
