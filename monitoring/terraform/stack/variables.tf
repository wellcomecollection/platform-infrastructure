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

variable "admin_cidr_ingress" {
  type = string
}

# Grafana
variable "grafana_version" {
  type = string
}

variable "grafana_admin_user" {
  type = string
}
variable "grafana_anonymous_role" {
  type = string
}
variable "grafana_admin_password" {
  type = string
}
variable "grafana_anonymous_enabled" {
  type = string
}

