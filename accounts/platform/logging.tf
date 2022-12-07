resource "aws_kinesis_stream" "logs_for_esf" {
  name = "logs-for-elastic-serverless-forwarder"

  enforce_consumer_deletion = true
  encryption_type           = "NONE"
  retention_period          = 3 * 24 // Give us 3 days to deal with issues ingesting logs

  stream_mode_details {
    stream_mode = "ON_DEMAND"
  }
}

module "elastic_log_forwarder" {
  source = "../modules/elastic_log_forwarder"

  kinesis_log_stream_arn = aws_kinesis_stream.logs_for_esf.arn
  es_data_stream         = "service-logs-esf"
}
