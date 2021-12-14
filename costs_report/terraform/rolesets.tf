module "platform_role" {
  source = "./roleset"

  providers = {
    aws = aws.platform
  }

  account_name = "platform"

  lambda_task_role_arn = module.costs_report_lambda.role_arn
}

module "catalogue_role" {
  source = "./roleset"

  providers = {
    aws = aws.catalogue
  }

  account_name = "catalogue"

  lambda_task_role_arn = module.costs_report_lambda.role_arn
}

module "storage_role" {
  source = "./roleset"

  providers = {
    aws = aws.storage
  }

  account_name = "storage"

  lambda_task_role_arn = module.costs_report_lambda.role_arn
}

module "workflow_role" {
  source = "./roleset"

  providers = {
    aws = aws.workflow
  }

  account_name = "workflow"

  lambda_task_role_arn = module.costs_report_lambda.role_arn
}

module "experience_role" {
  source = "./roleset"

  providers = {
    aws = aws.experience
  }

  account_name = "experience"

  lambda_task_role_arn = module.costs_report_lambda.role_arn
}

module "identity_role" {
  source = "./roleset"

  providers = {
    aws = aws.identity
  }

  account_name = "identity"

  lambda_task_role_arn = module.costs_report_lambda.role_arn
}

module "dam_prototype_role" {
  source = "./roleset"

  providers = {
    aws = aws.dam_prototype
  }

  account_name = "dam_prototype"

  lambda_task_role_arn = module.costs_report_lambda.role_arn
}

module "digirati_role" {
  source = "./roleset"

  providers = {
    aws = aws.digirati
  }

  account_name = "digirati"

  lambda_task_role_arn = module.costs_report_lambda.role_arn
}

module "data_role" {
  source = "./roleset"

  providers = {
    aws = aws.data
  }

  account_name = "data"

  lambda_task_role_arn = module.costs_report_lambda.role_arn
}

module "reporting_role" {
  source = "./roleset"

  providers = {
    aws = aws.reporting
  }

  account_name = "reporting"

  lambda_task_role_arn = module.costs_report_lambda.role_arn
}

module "digitisation_role" {
  source = "./roleset"

  providers = {
    aws = aws.digitisation
  }

  account_name = "digitisation"

  lambda_task_role_arn = module.costs_report_lambda.role_arn
}

# This is the config for the microsites account, which is a standalone
# account we're responsible for but which isn't tied to our Azure roles.
#
# These resources have been created so they're consistent with our other
# accounts, but they've been removed from the Terraform state.

/*module "microsites_role" {
  source = "./roleset"

  providers = {
    aws = aws.microsites
  }

  account_name = "microsites"

  lambda_task_role_arn = module.costs_report_lambda.role_arn
}*/

/*variable "microsites_access_key" {
  type = string
}

variable "microsites_secret_key" {
  type = string
}

provider "aws" {
  alias = "microsites"

  region = "eu-west-1"

  access_key = var.microsites_access_key
  secret_key = var.microsites_secret_key

  default_tags {
    tags = local.default_tags
  }
}*/
