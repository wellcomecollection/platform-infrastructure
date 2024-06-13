# Monitoring
## Slack alarms

We have Slack alerts for certain failures across the platform, which are published into the [#wc-platform-alerts channel][slack].
In particular:

*   We can alert on CloudWatch Alarms, which in turn are based on CloudWatch Metrics.
    e.g. we send alerts when there are messages on SQS dead-letter queues or 5xx errors in API Gateway and CloudFront.

*   We can alert on failed Lambda invocations.
    We set up [dead-letter config][lambda_dlq] for our asynchronous Lambdas, and then use CloudWatch Alarms to alert when the DLQ is non-empty.

*   We can alert on ECS tasks failing to start.
    We listen to the event stream from ECS, and identify events like

    > transformer_sierra is unable to consistently start tasks successfully

All these Lambdas are configured in this directory, for every account, and it exports SNS topic ARNs that can be used to hook into this alerting.

e.g. it exports `experience_cloudfront_alerts_topic_arn`, which will send alerts for CloudFront errors in the experience account.
We pull in that value in the Terraform configuration that defines that CloudFront distribution, connect it to the CloudWatch Alarm, and the alerts will appear when there are errors.

See [slack_alerts](./slack_alerts) for more information.

[slack]: https://app.slack.com/client/T0442CG7E/CQ720BG02/thread/C8X9YKM5X-1644319059.641309
[lambda_dlq]: https://docs.aws.amazon.com/lambda/latest/dg/invocation-async.html#invocation-dlq
