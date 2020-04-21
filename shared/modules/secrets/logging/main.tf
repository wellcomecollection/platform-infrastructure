module "logging_es_user" {
  source = "../../secret"
  
  name  = "logging_es_user"
  value = data.aws_secretsmanager_secret_version.logging_esuser_arn_default.secret_string
}

module "logging_es_pass" {
  source = "../../secret"

  name  = "logging_es_pass"
  value = data.aws_secretsmanager_secret_version.logging_espass_arn_default.secret_string
}

module "logging_es_host" {
  source = "../../secret"

  name  = "logging_es_host"
  value = data.aws_secretsmanager_secret_version.logging_eshost_arn_default.secret_string
}

module "logging_es_port" {
  source = "../../secret"

  name  = "logging_es_port"
  value = data.aws_secretsmanager_secret_version.logging_esport_arn_default.secret_string
}