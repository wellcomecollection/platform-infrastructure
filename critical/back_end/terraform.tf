terraform {
  required_version = ">= 0.9"

  required_providers {
    ec = {
      source  = "elastic/ec"
      version = "0.1.0-beta"
    }
  }

  backend "s3" {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"

    bucket         = "wellcomecollection-platform-infra"
    key            = "terraform/platform-infrastructure/shared.tfstate"
    dynamodb_table = "terraform-locktable"
    region         = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts_catalogue" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/platform-infrastructure/accounts/catalogue.tfstate"
    region = "eu-west-1"
  }
}

locals {
  catalogue_vpcs = data.terraform_remote_state.accounts_catalogue.outputs
}
