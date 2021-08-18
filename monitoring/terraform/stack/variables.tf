variable "namespace" {}

variable "namespace_id" {}
variable "vpc_id" {}

variable "efs_id" {}
variable "efs_security_group_id" {}

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

# IAM

variable "allow_cloudwatch_read_metrics_policy_json" {}
variable "cloudwatch_allow_filterlogs_policy_json" {}
