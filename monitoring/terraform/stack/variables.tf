variable "namespace" {}

variable "vpc_id" {}

variable "efs_id" {}
variable "efs_security_group_id" {}
variable "ec_privatelink_security_group_id" {
  type = string
}

variable "domain" {}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "infra_bucket" {}
variable "key_name" {}
variable "aws_region" {}
variable "admin_cidr_ingress" {}

# Grafana

variable "grafana_admin_user" {}
variable "grafana_anonymous_role" {}
variable "grafana_admin_password" {}
variable "grafana_anonymous_enabled" {}

