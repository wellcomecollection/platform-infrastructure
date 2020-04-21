data "aws_secretsmanager_secret" "secret_names" {
  for_each = var.secrets
  name     = each.value
  provider = aws.platform
}

data "aws_secretsmanager_secret_version" "secret_names" {
  for_each  = var.secrets
  secret_id = data.aws_secretsmanager_secret.secret_names[each.key].id
  provider  = aws.platform
}
