module "elastic_log_forwarder" {
  source = "./modules/elastic_log_forwarder"

  kinesis_log_stream_arn = module.kinesis_log_destination.kinesis_stream.arn
  es_data_stream         = module.esf_data_stream.name
  es_api_key_secret      = "elasticsearch/logging/esf/api_key"
}

module "kinesis_log_destination" {
  source = "./modules/kinesis_log_destination"

  name               = "esf-logs"
  source_account_ids = values(local.account_ids)
}

// Put this in parameter store rather than as an output
// so that our Lambdas don't need access to the whole critical stack state
locals {
  esf_destination_parameter_name = "/logging/esf/destination_arn"
}

resource "aws_ssm_parameter" "log_destination_arn_platform" {
  provider = aws.platform

  name      = local.esf_destination_parameter_name
  type      = "String"
  value     = module.kinesis_log_destination.cloudwatch_log_destination.arn
  overwrite = true
}

resource "aws_ssm_parameter" "log_destination_arn_catalogue" {
  provider = aws.catalogue

  name      = local.esf_destination_parameter_name
  type      = "String"
  value     = module.kinesis_log_destination.cloudwatch_log_destination.arn
  overwrite = true
}

resource "aws_ssm_parameter" "log_destination_arn_digirati" {
  provider = aws.digirati

  name      = local.esf_destination_parameter_name
  type      = "String"
  value     = module.kinesis_log_destination.cloudwatch_log_destination.arn
  overwrite = true
}

resource "aws_ssm_parameter" "log_destination_arn_experience" {
  provider = aws.experience

  name      = local.esf_destination_parameter_name
  type      = "String"
  value     = module.kinesis_log_destination.cloudwatch_log_destination.arn
  overwrite = true
}

resource "aws_ssm_parameter" "log_destination_arn_identity" {
  provider = aws.identity

  name      = local.esf_destination_parameter_name
  type      = "String"
  value     = module.kinesis_log_destination.cloudwatch_log_destination.arn
  overwrite = true
}

resource "aws_ssm_parameter" "log_destination_arn_reporting" {
  provider = aws.reporting

  name      = local.esf_destination_parameter_name
  type      = "String"
  value     = module.kinesis_log_destination.cloudwatch_log_destination.arn
  overwrite = true
}

resource "aws_ssm_parameter" "log_destination_arn_storage" {
  provider = aws.storage

  name      = local.esf_destination_parameter_name
  type      = "String"
  value     = module.kinesis_log_destination.cloudwatch_log_destination.arn
  overwrite = true
}

resource "aws_ssm_parameter" "log_destination_arn_workflow" {
  provider = aws.workflow

  name      = local.esf_destination_parameter_name
  type      = "String"
  value     = module.kinesis_log_destination.cloudwatch_log_destination.arn
  overwrite = true
}
