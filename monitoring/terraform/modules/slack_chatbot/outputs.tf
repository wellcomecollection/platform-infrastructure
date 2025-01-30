output "chatbot_topic_arn" {
  value = aws_sns_topic.chatbot_events.arn
}