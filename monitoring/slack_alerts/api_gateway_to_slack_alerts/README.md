# api_gateway_to_slack_alerts

We use API Gateway for our user-facing APIs.
We want to be alerted when an API returns a 5XX error.

<img src="api_gateway_alert_architecture.svg">

We create a CloudWatch alarm based on the errors returned by an API.
If there are 5XX errors, the alarm moves into the "In Alarm" state, which posts a notification to an SNS topic.

Notifications sent to this topic trigger this Lambda function, which sends a message to a shared Slack channel so we can see that something is up.

## Implementation notes

*   We have one topic/Lambda function per account, so we don't have to deal with cross-account permissions for the CloudWatch-to-SNS topic notification.
*   The ARNs of the per-account API Gateway alarm topics are published as outputs from the `monitoring` stack.

## How to deploy

The Lambda is automatically deployed when you run `terraform apply` in the monitoring stack.
