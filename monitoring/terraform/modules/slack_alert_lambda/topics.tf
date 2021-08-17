resource "aws_sns_topic" "topic" {
  name = "${var.account_name}_${var.topic_name}"
}
