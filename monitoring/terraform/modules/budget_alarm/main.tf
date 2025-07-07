# Data sources for SSM parameters
data "aws_ssm_parameter" "monthly_budget" {
  name = "/platform/budget/monthly"
}

data "aws_ssm_parameter" "email_notifications" {
  name = "/platform/budget/email_notifications"
}

# Local values for processing
locals {
  monthly_budget_amount = tonumber(data.aws_ssm_parameter.monthly_budget.value)
  email_notifications   = split(",", data.aws_ssm_parameter.email_notifications.value)
}

# SNS Topic for budget notifications
resource "aws_sns_topic" "budget_notifications" {
  name = "budget-notifications"
}

# SNS Topic subscriptions for email notifications
resource "aws_sns_topic_subscription" "budget_email_notifications" {
  count     = length(local.email_notifications)
  topic_arn = aws_sns_topic.budget_notifications.arn
  protocol  = "email"
  endpoint  = trimspace(local.email_notifications[count.index])
}

# Budget for actual spend
resource "aws_budgets_budget" "monthly_budget" {
  name              = "monthly-budget"
  budget_type       = "COST"
  limit_amount      = local.monthly_budget_amount
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2024-01-01_00:00"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = local.email_notifications
    subscriber_sns_topic_arns  = [aws_sns_topic.budget_notifications.arn]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 110
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = local.email_notifications
    subscriber_sns_topic_arns  = [aws_sns_topic.budget_notifications.arn]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = local.email_notifications
    subscriber_sns_topic_arns  = [aws_sns_topic.budget_notifications.arn]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 110
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = local.email_notifications
    subscriber_sns_topic_arns  = [aws_sns_topic.budget_notifications.arn]
  }
}

# CloudWatch alarms for budget monitoring
resource "aws_cloudwatch_metric_alarm" "budget_actual_alarm" {
  alarm_name          = "budget-actual-exceeded"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ActualCost"
  namespace           = "AWS/Budgets"
  period              = "86400" # 24 hours
  statistic           = "Maximum"
  threshold           = local.monthly_budget_amount * 1.0
  alarm_description   = "This alarm monitors when actual spend exceeds 100% of the monthly budget"
  alarm_actions       = [aws_sns_topic.budget_notifications.arn]

  dimensions = {
    BudgetName = aws_budgets_budget.monthly_budget.name
  }
}

resource "aws_cloudwatch_metric_alarm" "budget_forecasted_alarm" {
  alarm_name          = "budget-forecasted-exceeded"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ForecastedCost"
  namespace           = "AWS/Budgets"
  period              = "86400" # 24 hours
  statistic           = "Maximum"
  threshold           = local.monthly_budget_amount * 1.0
  alarm_description   = "This alarm monitors when forecasted spend exceeds 100% of the monthly budget"
  alarm_actions       = [aws_sns_topic.budget_notifications.arn]

  dimensions = {
    BudgetName = aws_budgets_budget.monthly_budget.name
  }
}