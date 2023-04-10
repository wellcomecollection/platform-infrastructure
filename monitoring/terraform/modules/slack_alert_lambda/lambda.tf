locals {
  source_name = var.source_name != "" ? var.source_name : var.name
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../../../slack_alerts/${local.source_name}/src"
  output_path = "${path.module}/${local.source_name}.zip"
}

module "lambda" {
  source = "../lambda"

  name        = "${var.account_name}_${var.name}"
  module_name = local.source_name
  description = var.description

  timeout = 10

  environment_variables = merge(
    {
      "ACCOUNT_NAME" = var.account_name
    },
    var.environment_variables
  )

  filename = data.archive_file.lambda.output_path

  alarm_topic_arn = var.alarm_topic_arn
}
