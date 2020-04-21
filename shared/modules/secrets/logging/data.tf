# User

data "aws_secretsmanager_secret" "logging_esuser_arn_default" {
  name = "shared/logging/es_user"

  provider = aws.platform
}

data "aws_secretsmanager_secret_version" "logging_esuser_arn_default" {
  secret_id = data.aws_secretsmanager_secret.logging_esuser_arn_default.id

  provider = aws.platform
}

# Pass

data "aws_secretsmanager_secret" "logging_espass_arn_default" {
  name = "shared/logging/es_pass"

  provider = aws.platform
}

data "aws_secretsmanager_secret_version" "logging_espass_arn_default" {
  secret_id = data.aws_secretsmanager_secret.logging_espass_arn_default.id

  provider = aws.platform
}

# Host

data "aws_secretsmanager_secret" "logging_eshost_arn_default" {
  name = "shared/logging/es_host"

  provider = aws.platform
}

data "aws_secretsmanager_secret_version" "logging_eshost_arn_default" {
  secret_id = data.aws_secretsmanager_secret.logging_eshost_arn_default.id

  provider = aws.platform
}

# Port

data "aws_secretsmanager_secret" "logging_esport_arn_default" {
  name = "shared/logging/es_port"

  provider = aws.platform
}

data "aws_secretsmanager_secret_version" "logging_esport_arn_default" {
  secret_id = data.aws_secretsmanager_secret.logging_esport_arn_default.id

  provider = aws.platform
}
