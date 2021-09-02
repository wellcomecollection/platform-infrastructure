module "platform_role" {
  source = "./roleset"

  providers = {
    aws = aws.platform
  }

  account_name = "platform"

  lambda_task_role_arn = module.costs_report_lambda.role_arn
}
