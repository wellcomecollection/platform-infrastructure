# slack_alerts

This is a collection of Lambda functions that send alerts to our Slack channels when something is broken.

Rough architecture:

<img src="slack_architecture.svg">

We define a series of CloudWatch Alarms, which monitor metrics from a variety of places, and take action when a metric hits some particular threshold.
One of the actions is to send a notification to an SNS topic, which triggers one of the Lambda functions defined in this directory.
That function sends a message to our Slack channel, so we know to act on it.

## Examples

We get warnings when SQS queues are non-empty:

![A yellow-badged Slack message saying "There are 129 items on the catalogue TEI transformer queue".](alert_sqs_queue_non_empty.png)

We get warnings when Lambda functions have an error, which include links to CloudWatch Logs from the time of the error:

![A Yellow-badged Slack message saying "There were 3 errors in the platform_example_lambda2" Lambda, followed by some logs and links to CloudWatch.](alert_lambda_error.png)

We get alerts when there are 5XX errors through API Gateway:

![A red-badged Slack message saying "There were 2 errors from API Gateway".](alert_api_gateway.png)

## Implementation notes

*   We have one topic/Lambda function per account, so we don't have to deal with cross-account permissions for the CloudWatch-to-SNS topic notification.
*   The ARNs of the per-account DLQ alarm topics are published as outputs from the `monitoring` stack.

## How to deploy

The Lambdas are automatically deployed when you run `terraform apply` in the monitoring stack.
