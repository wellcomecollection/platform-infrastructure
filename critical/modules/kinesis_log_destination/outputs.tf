output "cloudwatch_log_destination" {
  value = aws_cloudwatch_log_destination.kinesis
}

output "kinesis_stream" {
  value = aws_kinesis_stream.destination
}
