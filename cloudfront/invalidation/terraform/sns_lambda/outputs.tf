output "sns_topic_arn" {
  value = aws_sns_topic.sns_invalidation_topic.arn
}