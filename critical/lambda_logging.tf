module "log_data_stream" {
  source = "./modules/elasticsearch_data_stream"
  providers = {
    elasticstack = elasticstack.logging
  }

  stream_name            = "service-logs-forwarded"
  index_rollover_max_age = "1d"
  index_delete_after     = "30d"
}

resource "elasticstack_elasticsearch_security_api_key" "log_forwarder" {
  provider = elasticstack.logging

  name = "Elasticsearch log forwarder"

  role_descriptors = jsonencode({
    cluster-health = {
      cluster = ["monitor"]
    }
    write-to-stream = {
      indices = [
        {
          names      = [module.log_data_stream.name],
          privileges = ["create_index", "index", "create", "auto_configure"]
        }
      ]
    }
  })
}

module "kinesis_log_destination" {
  source = "./modules/kinesis_log_destination"

  name               = "elasticsearch-forwarder-logs"
  source_account_ids = values(local.account_ids)
}

// Put this in parameter store rather than as an output
// so that our Lambdas don't need access to the whole critical stack state
locals {
  log_destination_parameter_name = "/logging/forwarder/destination_arn"
}

resource "aws_ssm_parameter" "log_destination_arn_platform" {
  provider = aws.platform

  name  = local.log_destination_parameter_name
  type  = "String"
  value = module.kinesis_log_destination.cloudwatch_log_destination.arn
}

resource "aws_ssm_parameter" "log_destination_arn_catalogue" {
  provider = aws.catalogue

  name  = local.log_destination_parameter_name
  type  = "String"
  value = module.kinesis_log_destination.cloudwatch_log_destination.arn
}

resource "aws_ssm_parameter" "log_destination_arn_digirati" {
  provider = aws.digirati

  name  = local.log_destination_parameter_name
  type  = "String"
  value = module.kinesis_log_destination.cloudwatch_log_destination.arn
}

resource "aws_ssm_parameter" "log_destination_arn_experience" {
  provider = aws.experience

  name  = local.log_destination_parameter_name
  type  = "String"
  value = module.kinesis_log_destination.cloudwatch_log_destination.arn
}

resource "aws_ssm_parameter" "log_destination_arn_identity" {
  provider = aws.identity

  name  = local.log_destination_parameter_name
  type  = "String"
  value = module.kinesis_log_destination.cloudwatch_log_destination.arn
}

resource "aws_ssm_parameter" "log_destination_arn_reporting" {
  provider = aws.reporting

  name  = local.log_destination_parameter_name
  type  = "String"
  value = module.kinesis_log_destination.cloudwatch_log_destination.arn
}

resource "aws_ssm_parameter" "log_destination_arn_storage" {
  provider = aws.storage

  name  = local.log_destination_parameter_name
  type  = "String"
  value = module.kinesis_log_destination.cloudwatch_log_destination.arn
}

resource "aws_ssm_parameter" "log_destination_arn_workflow" {
  provider = aws.workflow

  name  = local.log_destination_parameter_name
  type  = "String"
  value = module.kinesis_log_destination.cloudwatch_log_destination.arn
}
