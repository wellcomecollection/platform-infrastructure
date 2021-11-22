locals {
  catalogue_account_id = "756629837203"
  platform_account_id  = "760097843905"
  storage_account_id   = "975596993436"
  workflow_account_id  = "299497370133"

  account_ids = [
    local.catalogue_account_id,
    local.platform_account_id,
    local.storage_account_id,
    local.workflow_account_id,
  ]
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${local.platform_account_id}:role/platform-admin"
  }
}
