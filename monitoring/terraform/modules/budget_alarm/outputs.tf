output "budget_name" {
  value       = aws_budgets_budget.monthly_budget.name
  description = "Name of the created budget"
}

output "budget_arn" {
  value       = aws_budgets_budget.monthly_budget.arn
  description = "ARN of the created budget"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.budget_notifications.arn
  description = "ARN of the SNS topic for budget notifications"
}

output "actual_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.budget_actual_alarm.arn
  description = "ARN of the CloudWatch alarm for actual spend"
}

output "forecasted_alarm_arn" {
  value       = aws_cloudwatch_metric_alarm.budget_forecasted_alarm.arn
  description = "ARN of the CloudWatch alarm for forecasted spend"
}

output "monthly_budget_amount" {
  value       = local.monthly_budget_amount
  description = "The monthly budget amount read from SSM"
}

output "email_notifications" {
  value       = local.email_notifications
  description = "List of email notification addresses"
  sensitive   = true
}
