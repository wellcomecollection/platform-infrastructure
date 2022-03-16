output "trigger_topic_arn" {
  value = aws_sns_topic.topic.arn
}

output "role_name" {
  value = module.lambda.role_name
}

