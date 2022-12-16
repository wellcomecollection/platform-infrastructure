module "elastic_log_forwarder" {
  source = "./modules/elastic_log_forwarder"

  kinesis_log_stream_arn = module.kinesis_log_destination.kinesis_stream.arn
  es_data_stream         = module.esf_data_stream.name
  es_api_key_secret      = "elasticsearch/logging/esf/api_key"
}

module "kinesis_log_destination" {
  source = "./modules/kinesis_log_destination"

  name = "esf-logs"
  source_account_ids = values(local.account_ids)
}

// Put this in parameter store rather than as an output
// so that our Lambdas don't need access to the whole critical stack state
resource "aws_ssm_parameter" "log_destination_arn" {
  name = "/logging/esf/destination_arn"
  type = "String"
  value = module.kinesis_log_destination.cloudwatch_log_destination.arn
}
