terraform {
  required_version = ">= 0.9"

  required_providers {
    ec = {
      source  = "elastic/ec"
      version = "0.5.0"
    }
    elasticstack = {
      source  = "elastic/elasticstack"
      version = "0.5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
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

data "terraform_remote_state" "accounts_platform" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/aws-account-infrastructure/platform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts_catalogue" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/aws-account-infrastructure/catalogue.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts_storage" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/aws-account-infrastructure/storage.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts_experience" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/aws-account-infrastructure/experience.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts_digirati" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/aws-account-infrastructure/digirati.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "accounts_identity" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::760097843905:role/platform-read_only"

    bucket = "wellcomecollection-platform-infra"
    key    = "terraform/aws-account-infrastructure/identity.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "workflow_prod" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::299497370133:role/workflow-read_only"

    bucket = "wellcomecollection-workflow-infra"
    key    = "terraform/workflow.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "workflow_stage" {
  backend = "s3"

  config = {
    role_arn = "arn:aws:iam::299497370133:role/workflow-read_only"

    bucket = "wellcomecollection-workflow-infra"
    key    = "terraform/workflow-stage.tfstate"
    region = "eu-west-1"
  }
}

locals {
  platform_vpcs   = data.terraform_remote_state.accounts_platform.outputs
  catalogue_vpcs  = data.terraform_remote_state.accounts_catalogue.outputs
  storage_vpcs    = data.terraform_remote_state.accounts_storage.outputs
  experience_vpcs = data.terraform_remote_state.accounts_experience.outputs
  digirati_vpcs   = data.terraform_remote_state.accounts_digirati.outputs
  identity_vpcs   = data.terraform_remote_state.accounts_identity.outputs

  workflow_prod_vpcs  = data.terraform_remote_state.workflow_prod.outputs
  workflow_stage_vpcs = data.terraform_remote_state.workflow_stage.outputs
}
