# Budget Alarm Module

This Terraform module creates AWS budget alarms that monitor monthly spending and send notifications when thresholds are exceeded.

## Features

- Reads monthly budget amount from SSM parameter `/platform/budget/monthly`
- Reads notification email addresses from SSM parameter `/platform/budget/notification_emails` (comma-separated)
- Creates AWS Budget with notifications for both actual and forecasted spend
- Creates CloudWatch alarms for monitoring
- Sends notifications via SNS topic and email

## SSM Parameters Required

1. `/platform/budget/monthly` - Integer value representing the monthly budget in USD
2. `/platform/budget/notification_emails` - Comma-separated list of email addresses

## AWS Spending Analysis Script

This module includes a helper script (`scripts/aws_spending.py`) for analyzing AWS spending across developer accounts and managing budget parameters.

### Script Features

- **Cost Analysis**: View spending reports for individual accounts or all accounts
- **Budget Initialization**: Automatically set budget parameters based on historical spending
- **SSM Parameter Management**: Create and update budget configuration parameters
- **Multiple Output Formats**: Detailed reports, summary-only, or individual account analysis

### Script Usage

The script requires AWS credentials with permissions to assume the developer roles and access Cost Explorer and SSM services.

```bash
# Make the script executable
chmod +x scripts/aws_spending.py

# View help
./scripts/aws_spending.py --help

# Show cost analysis for all accounts
./scripts/aws_spending.py --all

# Show summary only (no individual account details)
./scripts/aws_spending.py --summary-only

# Show specific account(s)
./scripts/aws_spending.py --account catalogue
./scripts/aws_spending.py --account platform --account storage

# List available accounts
./scripts/aws_spending.py --list-accounts

# Initialize budget parameters for an account (110% of average spend)
./scripts/aws_spending.py --init-budget catalogue

# Initialize budget parameters for all accounts
./scripts/aws_spending.py --init-all-budgets

# Initialize with custom budget percentage
./scripts/aws_spending.py --init-budget platform --budget-percentage 120

# Initialize with custom email address
./scripts/aws_spending.py --init-budget workflow --email-address team@example.com

# Initialize all accounts with custom settings
./scripts/aws_spending.py --init-all-budgets --budget-percentage 105 --email-address devs@wellcomecollection.org
```

### Script Configuration

The script is pre-configured with developer role ARNs for the following accounts:
- catalogue, data, digirati, digitisation, experience, identity, microsites, platform, reporting, storage, systems_strategy, workflow

### Budget Initialization

The `--init-budget` option calculates a budget based on the average monthly spend over the last 6 months and sets the SSM parameters. The `--init-all-budgets` option performs the same initialization for all configured accounts at once.

- **Default Budget**: 110% of average monthly spend
- **Default Email**: digital@wellcomecollection.org
- **SSM Parameters Created/Updated**:
  - `/platform/budget/monthly` - Monthly budget amount in USD
  - `/platform/budget/email_notifications` - Comma-separated email addresses

### Prerequisites

- AWS CLI configured with appropriate permissions
- Python 3.x with required dependencies:
  - `boto3`
  - `python-dateutil`
- Access to assume the developer roles listed in the script
- Permissions for Cost Explorer and SSM Parameter Store access

## Usage

```hcl
module "budget_alarm" {
  source = "./modules/budget_alarm"

  budget_name = "platform-monthly-budget"
  
  alarm_actions = [
    "arn:aws:sns:us-east-1:123456789012:additional-topic"
  ]

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

## Notifications

The module creates notifications at the following thresholds:
- 100% of budget (actual spend)
- 110% of budget (actual spend)
- 100% of budget (forecasted spend)
- 110% of budget (forecasted spend)

## Resources Created

- `aws_budgets_budget` - Monthly budget with cost monitoring
- `aws_sns_topic` - SNS topic for budget notifications
- `aws_sns_topic_subscription` - Email subscriptions for notifications
- `aws_cloudwatch_metric_alarm` - CloudWatch alarms for actual and forecasted spend

## Outputs

- `budget_name` - Name of the created budget
- `budget_arn` - ARN of the created budget
- `sns_topic_arn` - ARN of the SNS topic for notifications
- `actual_alarm_arn` - ARN of the actual spend alarm
- `forecasted_alarm_arn` - ARN of the forecasted spend alarm
- `monthly_budget_amount` - The budget amount read from SSM
- `notification_emails` - List of notification emails (sensitive)

## Variables

- `budget_name` - Name for the budget (default: "monthly-budget")
- `alarm_actions` - List of ARNs to notify when alarms are triggered (default: [])
- `tags` - Tags to apply to resources (default: {})
