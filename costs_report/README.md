# costs_report

This is a monthly report of our cloud costs, to give us more visibility over how much we're spending:

![A Slack message from an app named "costs-report". The message is titled "Costs report for September 2021" and includes a table in a monospaced code block. The table has three columns: "account", "prev 3 months ($)" and "last month". There are five rows for individual items and a TOTAL, and on the right hand side are up/down arrows to show cost increase/decreases.](screenshot.png)

For example, this report tells us that in June/July/August we spent an average of $4900 per month, then we spent $5255 in September – a 7% increase.

These reports run once a month and post into a Slack channel, so everyone in the platform team can see what we're spending.

## Our approach to cost management

We want to spend money responsibly.
Our budget isn't unlimited, but nor is it tight.

Right now, we want to understand why we're spending money, rather than get the absolute smallest bill.
We want to avoid our bill growing in an unbounded way, or for an unexplained reason.

It's good for developers to have a general awareness of our cloud bill.
Every developer can look at the bill in the AWS console, and this report is posted into a shared channel.

## Requirements

The report is designed to:

*   Give us a regular reminder of the general direction of the bill.
    Is the bill going up, down, or constant?
*   Highlight significant changes as compared to the average of the previous three months (±5% or more).
    Small month-to-month variations are fine.
*   Combine costs information across all our AWS accounts and other major cloud providers, e.g. Elastic Cloud.
    The report has both an itemised list of per-account/provider costs, and the total figure.

**The report is working if it starts conversations about significant changes in the bill.**
It might be fine if an account's bill doubles in a single month, as long as we understand why.
For example, if we ingest a lot of new content in the storage service, we'd expect to see a big bill in the storage account.
But if the bill doubles and nobody knows why, that needs further investigation.

## Modifying the report

This report runs as a Lambda function, triggered by a CloudWatch Event Rule that fires once a month.

### Deployment

The Lambda is deployed when you run `terraform apply`.

### Local development

If you want to test the Lambda, you can run the report locally:

```console
$ python3 costs_report/costs_report.py
```

This just prints the ASCII table, and doesn't post a message to Slack.

### Adding a new AWS account

The Terraform creates a new role in each account, which just allows permission to read the billing data.
You need to:

*   Create that role in Terraform, using the `roleset` module
*   Give the Lambda permission to assume the role

See [commit 2af1f1b](https://github.com/wellcomecollection/platform-infrastructure/commit/2af1f1bc24d282c13f5ce290c27a60cc2e7286dc) and [cb2a39f](https://github.com/wellcomecollection/platform-infrastructure/commit/cb2a39fcde4b65f6ab51e1a34f782e442ded720b#diff-553d8343b3da113c8b87417d57d38f3efae186331cf32538e6c67dec37d298ae) as an example of adding a new account.
