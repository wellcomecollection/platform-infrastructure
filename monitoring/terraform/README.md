# Terraforming the monitoring infrastructure

## Unexpected changes

When running terraform plan, you may see some unexpected changes, reporting that some eu-west-1 resources will
change to us-east-1 (see below).

Although this is irritating, it appears to have no effect, so is nothing to worry about.  Do not let it block you
from deploying the changes you actually expect.

```
# module.experience_cloudfront_alerts.module.lambda_error_alerts.module.lambda_errors_to_slack_alerts.module.lambda.aws_iam_role_policy.cloudwatch_logs will be updated in-place

~ resource "aws_iam_role_policy" "cloudwatch_logs" {
id     = "lambda_experience_lambda_errors_to_slack_alerts_iam_role:lambda_experience_lambda_errors_to_slack_alerts_iam_role_lambda_cloudwatch_logs"
name   = "lambda_experience_lambda_errors_to_slack_alerts_iam_role_lambda_cloudwatch_logs"
~ policy = jsonencode(
~ {
~ Statement = [
~ {
~ Resource = [
- "arn:aws:logs:eu-west-1:130871440101:log-group:/aws/lambda/experience_lambda_errors_to_slack_alerts:*",
- "arn:aws:logs:eu-west-1:130871440101:log-group:/aws/lambda/experience_lambda_errors_to_slack_alerts",
+ "arn:aws:logs:us-east-1:130871440101:log-group:/aws/lambda/experience_lambda_errors_to_slack_alerts:*",
+ "arn:aws:logs:us-east-1:130871440101:log-group:/aws/lambda/experience_lambda_errors_to_slack_alerts",
]
# (3 unchanged elements hidden)
},
]
# (1 unchanged element hidden)
}
)
# (1 unchanged attribute hidden)
}

# module.experience_cloudfront_alerts.module.lambda_error_alerts.module.lambda_errors_to_slack_alerts.module.lambda.aws_iam_role_policy.lambda_dlq will be updated in-place
~ resource "aws_iam_role_policy" "lambda_dlq" {
id     = "lambda_experience_lambda_errors_to_slack_alerts_iam_role:lambda_experience_lambda_errors_to_slack_alerts_iam_role_lambda_dlq"
name   = "lambda_experience_lambda_errors_to_slack_alerts_iam_role_lambda_dlq"
~ policy = jsonencode(
~ {
~ Statement = [
~ {
~ Resource = "arn:aws:sqs:eu-west-1:130871440101:lambda-experience_lambda_errors_to_slack_alerts_dlq" -> "arn:aws:sqs:us-east-1:130871440101:lambda-experience_lambda_errors_to_slack_alerts_dlq"
# (3 unchanged elements hidden)
},
]
# (1 unchanged element hidden)
}
)
# (1 unchanged attribute hidden)
}

```

## Grafana Loadbalancer Security Group

The Grafana loadbalancer security group is normally maintained manually, so changes are ignored by Terraform.
To reset it, change the ignore_changes definition in [security_groups.tf](stack/grafana/security_groups.tf).