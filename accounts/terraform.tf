terraform {
  required_version = ">= 0.9"

  backend "s3" {
    bucket         = "wellcomecollection-platform-infra"
    key            = "terraform/platform-infrastructure/accounts.tfstate"
    dynamodb_table = "terraform-locktable"

    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
    region   = "eu-west-1"
  }
}

data "terraform_remote_state" "builds" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-developer"
    bucket   = "wellcomecollection-platform-infra"
    key      = "terraform/builds.tfstate"
    region   = "eu-west-1"
  }
}

data "terraform_remote_state" "storage" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::975596993436:role/storage-read_only"


    bucket = "wellcomecollection-storage-infra"
    key    = "terraform/storage-private.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "experience" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::130871440101:role/experience-read_only"

    bucket = "wellcomecollection-infra"
    key    = "build-state/terraform-config.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "data" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::964279923020:role/data-read_only"

    bucket = "wellcomecollection-datascience-infra"
    key    = "terraform/datascience-private.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "reporting" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::269807742353:role/reporting-read_only"

    bucket = "wellcomecollection-reporting-infra"
    key    = "terraform/reporting-private.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "digitisation" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::404315009621:role/digitisation-read_only"

    bucket = "wellcomedigitisation-infra"
    key    = "terraform/digitisation-private.tfstate"
    region = "eu-west-1"
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

data "terraform_remote_state" "accounts_data" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/platform-infrastructure/accounts/data.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts_digirati" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/platform-infrastructure/accounts/digirati.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts_digitisation" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/platform-infrastructure/accounts/digitisation.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts_experience" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/platform-infrastructure/accounts/experience.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts_reporting" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/platform-infrastructure/accounts/reporting.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts_storage" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/platform-infrastructure/accounts/storage.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts_workflow" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/platform-infrastructure/accounts/workflow.tfstate"
    region = "eu-west-1"
  }
}

data "aws_caller_identity" "current" {}

data "template_file" "pgp_key" {
  template = file("${path.module}/wellcomedigitalplatform.pub")
}

locals {
  account_id        = data.aws_caller_identity.current.account_id
  aws_principal     = "arn:aws:iam::${local.account_id}:root"
  ci_agent_role_arn = data.terraform_remote_state.builds.outputs.ci_role_arn

  catalogue_account_roles    = data.terraform_remote_state.accounts_catalogue.outputs
  data_account_roles         = data.terraform_remote_state.accounts_data.outputs
  digirati_account_roles     = data.terraform_remote_state.accounts_digirati.outputs
  digitisation_account_roles = data.terraform_remote_state.accounts_digitisation.outputs
  experience_account_roles   = data.terraform_remote_state.accounts_experience.outputs
  reporting_account_roles    = data.terraform_remote_state.accounts_reporting.outputs
  storage_account_roles      = data.terraform_remote_state.accounts_storage.outputs
  workflow_account_roles     = data.terraform_remote_state.accounts_workflow.outputs

  account_ids = {
    platform     = local.account_id
  }

  account_principals = { for key, value in local.account_ids : key => "arn:aws:iam::${value}:root" }
}
