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
