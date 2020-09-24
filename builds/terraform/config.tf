data "aws_ssm_parameter" "non_critical_slack_webhook" {
  name = "/aws/reference/secretsmanager/builds/non_critical_slack_webhook"
}

locals {
  non_critical_slack_webhook = data.aws_ssm_parameter.non_critical_slack_webhook.value
}
