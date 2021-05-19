locals {
  account_id                          = data.aws_caller_identity.current.account_id
  aws_platform_principal              = "arn:aws:iam::${local.account_id}:root"
}