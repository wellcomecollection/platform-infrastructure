locals {
  account_ids = {
    platform = "760097843905"
    identity = "770700576653"
  }

  aws_region = "eu-west-1"

  secrets_base_arn   = "arn:aws:secretsmanager:${local.aws_region}:${local.account_ids["identity"]}:secret:"
  ssm_param_base_arn = "arn:aws:ssm:${local.aws_region}:${local.account_ids["identity"]}:parameter/"

  account_principals = { for key, value in local.account_ids : key => "arn:aws:iam::${value}:root" }
}
