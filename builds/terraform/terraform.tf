terraform {
  required_version = ">= 0.11"

  backend "s3" {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"

    bucket         = "wellcomecollection-platform-infra"
    key            = "terraform/builds.tfstate"
    dynamodb_table = "terraform-locktable"
    region         = "eu-west-1"
  }
}

data "terraform_remote_state" "shared_infra" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/platform-infrastructure/shared.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/platform-infrastructure/accounts/platform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "critical_back_end" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"

    bucket         = "wellcomecollection-platform-infra"
    key            = "terraform/platform-infrastructure/shared.tfstate"
    region         = "eu-west-1"
  }
}