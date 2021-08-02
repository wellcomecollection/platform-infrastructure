resource "aws_sns_topic" "dlq_alarms" {
  name = "dlq_non_empty_alarm"
}
