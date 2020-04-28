locals {
  name_value_map = { for k, v in var.secrets : v => data.aws_secretsmanager_secret_version.secret_names[k].secret_string }
}