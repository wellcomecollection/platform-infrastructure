resource "aws_sns_topic" "dlq_alarms" {
  name = "${var.account_name}_dlq_non_empty_alarm"
}
