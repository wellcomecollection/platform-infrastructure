// This application is documented here:
// https://github.com/elastic/elastic-serverless-forwarder/blob/main/docs/README-AWS.md
data "aws_serverlessapplicationrepository_application" "esf_sar" {
  application_id = "arn:aws:serverlessrepo:eu-central-1:267093732750:applications/elastic-serverless-forwarder"
}

resource "aws_serverlessapplicationrepository_cloudformation_stack" "esf_cf_stack" {
  name             = "elastic-serverless-forwarder"
  application_id   = data.aws_serverlessapplicationrepository_application.esf_sar.application_id
  semantic_version = data.aws_serverlessapplicationrepository_application.esf_sar.semantic_version
  capabilities     = data.aws_serverlessapplicationrepository_application.esf_sar.required_capabilities

  parameters = {
    ElasticServerlessForwarderS3ConfigFile  = "s3://${aws_s3_object.esf_config.bucket}/${aws_s3_object.esf_config.key}"
    ElasticServerlessForwarderSSMSecrets    = join(",", [local.host_secret_arn, local.api_key_secret_arn])
    ElasticServerlessForwarderKinesisEvents = var.kinesis_log_stream_arn
  }
}

resource "aws_s3_object" "esf_config" {
  bucket = "wellcomecollection-platform-infra"
  key    = "platform-terraform-objects/elastic-serverless-forwarder-config.yml"

  content = templatefile(
    "${path.module}/config.yml.tftpl",
    {
      kinesis_stream_arn  = var.kinesis_log_stream_arn
      es_url_secret_arn   = local.host_secret_arn
      api_key_secret_arn  = local.api_key_secret_arn
      es_data_stream_name = "service-logs-esf"
    }
  )
}

locals {
  host_secret_arn    = data.aws_secretsmanager_secret.logging_es_public_host.arn
  api_key_secret_arn = data.aws_secretsmanager_secret.logging_es_api_key.arn
}

data "aws_secretsmanager_secret" "logging_es_public_host" {
  name = "elasticsearch/logging/public_host"
}

data "aws_secretsmanager_secret" "logging_es_api_key" {
  name = "elasticsearch/logging/esf/api_key"
}
