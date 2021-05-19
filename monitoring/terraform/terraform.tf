# Terraform config

terraform {
  required_version = ">= 0.10"

  backend "s3" {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"

    bucket         = "wellcomecollection-platform-infra"
    key            = "terraform/monitoring.tfstate"
    dynamodb_table = "terraform-locktable"
    region         = "eu-west-1"
  }
}

# Data

data "terraform_remote_state" "loris" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/loris.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "shared_infra" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/platform-infrastructure/accounts/shared.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts_platform" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/platform-infrastructure/accounts/platform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  shared_infra  = data.terraform_remote_state.shared_infra.outputs
  platform_vpcs = data.terraform_remote_state.accounts_platform.outputs
}